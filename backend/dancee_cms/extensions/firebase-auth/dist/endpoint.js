"use strict";

const admin = require("firebase-admin");
const jwt = require("jsonwebtoken");
const { randomBytes } = require("crypto");

module.exports = {
  id: "firebase",
  handler: (router, { services, env, database, getSchema, logger }) => {
    /**
     * POST /firebase/link
     *
     * Validates a Firebase ID token and creates a Directus user if one does
     * not already exist. Returns the Directus user object.
     *
     * Body: { "id_token": "<Firebase ID Token>" }
     */
    router.post("/link", async (req, res, next) => {
      try {
        const idToken = req.body?.id_token;
        if (!idToken) {
          return res.status(400).json({ error: "id_token is required." });
        }

        // Verify Firebase token
        let decodedToken;
        try {
          decodedToken = await admin.auth().verifyIdToken(idToken);
        } catch (error) {
          logger.info(`[Firebase Auth] Token verification failed: ${error.message}`);
          return res.status(401).json({ error: "Invalid Firebase token." });
        }

        const { email, uid, name } = decodedToken;
        if (!email) {
          return res.status(400).json({ error: "Firebase token does not contain an email." });
        }

        const schema = await getSchema();
        const { UsersService, RolesService } = services;

        const usersService = new UsersService({ schema, knex: database });
        const rolesService = new RolesService({ schema, knex: database });

        // Find existing user by email
        const existingUsers = await usersService.readByQuery({
          filter: { email: { _eq: email } },
          limit: 1,
        });

        if (existingUsers.length > 0) {
          // Update external_identifier if not set
          const user = existingUsers[0];
          if (!user.external_identifier) {
            await usersService.updateOne(user.id, {
              external_identifier: uid,
              provider: "firebase",
            });
          }
          return res.json({ data: { id: user.id, email: user.email, role: user.role } });
        }

        // Find the role for Firebase users
        const roleName = env.FIREBASE_ROLE_NAME || "User";
        const roles = await rolesService.readByQuery({
          filter: { name: { _eq: roleName } },
          limit: 1,
        });

        if (!roles || roles.length === 0) {
          logger.error(`[Firebase Auth] Role "${roleName}" not found in Directus.`);
          return res.status(500).json({ error: `Role "${roleName}" not found.` });
        }

        const role = roles[0];

        // Create new Directus user
        const userId = await usersService.createOne({
          email,
          first_name: name || email.split("@")[0],
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

    /**
     * POST /firebase/auth
     *
     * Generates Directus access and refresh tokens for a Firebase user.
     * The user must have been linked first via /firebase/link.
     *
     * Body: { "uid": "<Firebase User UID>" }
     */
    router.post("/auth", async (req, res, next) => {
      try {
        const { uid } = req.body || {};
        if (!uid) {
          return res.status(400).json({ error: "uid is required." });
        }

        const schema = await getSchema();
        const { UsersService, RolesService } = services;

        const usersService = new UsersService({ schema, knex: database });
        const rolesService = new RolesService({ schema, knex: database });

        // Find user by external_identifier (Firebase UID)
        const users = await usersService.readByQuery({
          filter: { external_identifier: { _eq: uid } },
          limit: 1,
        });

        if (!users || users.length === 0) {
          return res.status(404).json({ error: "User not found. Call /firebase/link first." });
        }

        const user = users[0];
        const role = await rolesService.readOne(user.role);

        // Build JWT payload
        const tokenPayload = {
          id: user.id,
          role: user.role,
          app_access: role.app_access || false,
          admin_access: role.admin_access || false,
        };

        const accessTokenTTL = env.ACCESS_TOKEN_TTL || "15m";
        const refreshTokenTTL = env.REFRESH_TOKEN_TTL || "7d";

        // Sign Directus access token
        const accessToken = jwt.sign(tokenPayload, env.SECRET, {
          expiresIn: accessTokenTTL,
          issuer: "directus",
        });

        // Generate refresh token
        const refreshToken = randomBytes(48).toString("hex");

        // Parse TTL to milliseconds for the response
        const expiresMs = parseTTL(accessTokenTTL);

        // Calculate refresh token expiration
        const refreshExpiresMs = parseTTL(refreshTokenTTL);
        const refreshExpiration = new Date(Date.now() + refreshExpiresMs);

        // Store session in directus_sessions
        await database("directus_sessions").insert({
          token: refreshToken,
          user: user.id,
          expires: refreshExpiration,
          ip: req.ip,
          user_agent: req.headers["user-agent"] || null,
        });

        // Update last access
        await database("directus_users")
          .update({ last_access: new Date() })
          .where({ id: user.id });

        // Clean up expired sessions
        await database("directus_sessions")
          .delete()
          .where("expires", "<", new Date());

        logger.info(`[Firebase Auth] Issued tokens for user ${user.email}.`);

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
  },
};

/**
 * Parses a TTL string (e.g. "15m", "7d", "1h") to milliseconds.
 */
function parseTTL(ttl) {
  if (typeof ttl === "number") return ttl;
  const match = String(ttl).match(/^(\d+)([smhd])$/);
  if (!match) return 900000; // default 15 min
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
