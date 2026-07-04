import admin from "firebase-admin";
import jwt from "jsonwebtoken";
import { randomBytes } from "crypto";

// Initialize Firebase Admin on first import
function ensureFirebaseInitialized(env, logger) {
  if (admin.apps.length > 0) return true;

  const credentialsBase64 = env.FIREBASE_CREDENTIALS_BASE64;
  if (!credentialsBase64) {
    logger.warn("[Firebase Auth] FIREBASE_CREDENTIALS_BASE64 not set.");
    return false;
  }

  try {
    const credentials = JSON.parse(
      Buffer.from(credentialsBase64, "base64").toString("utf-8")
    );
    admin.initializeApp({ credential: admin.credential.cert(credentials) });
    logger.info("[Firebase Auth] Firebase initialized successfully.");
    return true;
  } catch (error) {
    logger.error(`[Firebase Auth] Failed to initialize: ${error.message}`);
    return false;
  }
}

export default (router, { services, env, database, getSchema, logger }) => {
  logger.info("[Firebase Auth] Extension loaded, registering routes...");

  router.post("/link", async (req, res, next) => {
    try {
      if (!ensureFirebaseInitialized(env, logger)) {
        return res.status(500).json({ error: "Firebase not configured." });
      }

      const idToken = req.body?.id_token;
      if (!idToken) {
        return res.status(400).json({ error: "id_token is required." });
      }

      let decodedToken;
      try {
        decodedToken = await admin.auth().verifyIdToken(idToken, true);
      } catch (error) {
        logger.info(`[Firebase Auth] Token verification failed: ${error.message}`);
        return res.status(401).json({ error: "Invalid Firebase token." });
      }

      if (!decodedToken.email_verified) {
        return res.status(403).json({ error: "Firebase email is not verified." });
      }

      const { email, uid, name } = decodedToken;
      if (!email) {
        return res.status(400).json({ error: "Firebase token does not contain an email." });
      }

      const schema = await getSchema();
      const { UsersService, RolesService } = services;
      const usersService = new UsersService({ schema, knex: database });
      const rolesService = new RolesService({ schema, knex: database });

      const existingUsers = await usersService.readByQuery({
        filter: { email: { _eq: email } },
        limit: 1,
      });

      if (existingUsers.length > 0) {
        const user = existingUsers[0];
        const updates = {};
        // Always update external_identifier to current Firebase UID
        if (user.external_identifier !== uid) {
          updates.external_identifier = uid;
          updates.provider = "firebase";
        }
        // Update name from Firebase token if available and Directus name is empty
        if (name && (!user.first_name || user.first_name === email.split("@")[0])) {
          const parts = name.split(" ");
          updates.first_name = parts[0] || name;
          updates.last_name = parts.slice(1).join(" ") || null;
        }
        if (Object.keys(updates).length > 0) {
          await usersService.updateOne(user.id, updates);
          logger.info(`[Firebase Auth] Updated user ${email}: ${JSON.stringify(updates)}`);
        }
        return res.json({ data: { id: user.id, email: user.email, role: user.role } });
      }

      const roleName = env.FIREBASE_ROLE_NAME || "User";
      const roles = await rolesService.readByQuery({
        filter: { name: { _eq: roleName } },
        limit: 1,
      });

      if (!roles || roles.length === 0) {
        logger.error(`[Firebase Auth] Role "${roleName}" not found.`);
        return res.status(500).json({ error: `Role "${roleName}" not found.` });
      }

      const role = roles[0];

      const nameParts = name ? name.split(" ") : [];
      const firstName = nameParts[0] || email.split("@")[0];
      const lastName = nameParts.slice(1).join(" ") || null;

      const userId = await usersService.createOne({
        email,
        first_name: firstName,
        last_name: lastName,
        external_identifier: uid,
        provider: "firebase",
        role: role.id,
      });

      const newUser = await usersService.readOne(userId);
      logger.info(`[Firebase Auth] Created user ${email} (${userId}).`);

      return res.json({ data: { id: newUser.id, email: newUser.email, role: newUser.role } });
    } catch (error) {
      logger.error(`[Firebase Auth] Error in /link: ${error.message}`);
      return next(error);
    }
  });

  logger.info("[Firebase Auth] /link route registered");

  router.post("/auth", async (req, res, next) => {
    try {
      if (!ensureFirebaseInitialized(env, logger)) {
        return res.status(500).json({ error: "Firebase not configured." });
      }

      const idToken = req.body?.id_token;
      if (!idToken) {
        return res.status(400).json({ error: "id_token is required." });
      }

      let decoded;
      try {
        decoded = await admin.auth().verifyIdToken(idToken, true);
      } catch {
        return res.status(401).json({ error: "Invalid Firebase token." });
      }

      if (!decoded.email_verified) {
        return res.status(403).json({ error: "Email not verified." });
      }

      const uid = decoded.uid; // derived from verified token, never from req.body

      const schema = await getSchema();
      const { UsersService, RolesService } = services;
      const usersService = new UsersService({ schema, knex: database });
      const rolesService = new RolesService({ schema, knex: database });

      const users = await usersService.readByQuery({
        filter: { external_identifier: { _eq: uid } },
        limit: 1,
      });

      if (!users || users.length === 0) {
        return res.status(404).json({ error: "User not found. Call /firebase/link first." });
      }

      const user = users[0];
      const role = await rolesService.readOne(user.role);

      const tokenPayload = {
        id: user.id,
        role: user.role,
        app_access: role.app_access || false,
        admin_access: role.admin_access || false,
      };

      const accessTokenTTL = env.ACCESS_TOKEN_TTL || "15m";
      const refreshTokenTTL = env.REFRESH_TOKEN_TTL || "7d";

      const accessToken = jwt.sign(tokenPayload, env.SECRET, {
        expiresIn: accessTokenTTL,
        issuer: "directus",
      });

      const refreshToken = randomBytes(32).toString("hex");
      const expiresMs = parseTTL(accessTokenTTL);
      const refreshExpiresMs = parseTTL(refreshTokenTTL);
      const refreshExpiration = new Date(Date.now() + refreshExpiresMs);

      await database("directus_sessions").insert({
        token: refreshToken,
        user: user.id,
        expires: refreshExpiration,
        ip: req.ip,
        user_agent: req.headers["user-agent"] || null,
      });

      await database("directus_users")
        .update({ last_access: new Date() })
        .where({ id: user.id });

      await database("directus_sessions")
        .delete()
        .where("expires", "<", new Date());

      logger.debug(`[Firebase Auth] Issued tokens for user id=${user.id}.`);

      return res.json({
        data: {
          access_token: accessToken,
          refresh_token: refreshToken,
          expires: expiresMs,
        },
      });
    } catch (error) {
      logger.error(`[Firebase Auth] Error in /auth: ${error.message}`);
      return next(error);
    }
  });

  logger.info("[Firebase Auth] /auth route registered");
};

function parseTTL(ttl) {
  if (typeof ttl === "number") return ttl;
  const match = String(ttl).match(/^(\d+)([smhd])$/);
  if (!match) return 900000;
  const value = parseInt(match[1], 10);
  const unit = match[2];
  switch (unit) {
    case "s": return value * 1000;
    case "m": return value * 60 * 1000;
    case "h": return value * 60 * 60 * 1000;
    case "d": return value * 24 * 60 * 60 * 1000;
    default: return 900000;
  }
}
