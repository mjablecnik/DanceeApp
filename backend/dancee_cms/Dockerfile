FROM directus/directus:11.17.3

USER root
RUN corepack enable
USER node

# Install dependencies required by our custom Firebase Auth extension
RUN pnpm install firebase-admin jsonwebtoken

# Copy custom extension into the extensions directory
COPY extensions/firebase-auth /directus/extensions/firebase-auth
