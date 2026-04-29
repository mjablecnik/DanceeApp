FROM directus/directus:11.17.3

USER root
RUN corepack enable
USER node

RUN pnpm install directus-extension-bundle-firebase
