"use strict";

const admin = require("firebase-admin");

module.exports = ({ init }, { env, logger }) => {
  init("app.before", () => {
    const credentialsBase64 = env.FIREBASE_CREDENTIALS_BASE64;

    if (!credentialsBase64) {
      logger.warn("[Firebase Auth] FIREBASE_CREDENTIALS_BASE64 not set — skipping initialization.");
      return;
    }

    if (admin.apps.length > 0) {
      logger.info("[Firebase Auth] Firebase already initialized.");
      return;
    }

    try {
      const credentials = JSON.parse(
        Buffer.from(credentialsBase64, "base64").toString("utf-8")
      );

      admin.initializeApp({
        credential: admin.credential.cert(credentials),
      });

      logger.info("[Firebase Auth] Firebase initialized successfully.");
    } catch (error) {
      logger.error(`[Firebase Auth] Failed to initialize Firebase: ${error.message}`);
    }
  });
};
