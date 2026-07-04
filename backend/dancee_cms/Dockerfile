FROM directus/directus:11.17.3

USER root
RUN corepack enable

# Copy extension and fix ownership for node user
COPY firebase-extension /directus/extensions/directus-extension-firebase-auth
RUN chown -R node:node /directus/extensions/directus-extension-firebase-auth

USER node

# Install extension's own dependencies.
# TODO: commit a pnpm-lock.yaml and add --frozen-lockfile to prevent silent version drift.
RUN cd /directus/extensions/directus-extension-firebase-auth && pnpm install --prod
