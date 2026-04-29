# =============================================================================
# Stage 1: Build Flutter web app
# =============================================================================
FROM ghcr.io/cirruslabs/flutter:3.29.2 AS build

WORKDIR /app

# Copy dependency manifests first (layer caching)
COPY pubspec.yaml pubspec.lock ./

# Get dependencies
RUN flutter config --no-analytics \
    && flutter pub get

# Copy config files needed for code generation
COPY slang.yaml analysis_options.yaml ./

# Copy source code
COPY lib ./lib
COPY web ./web

# Run code generation (slang translations, freezed, go_router_builder)
RUN flutter pub run build_runner build --delete-conflicting-outputs

# Build for web
RUN flutter build web --release --base-href="/"

# =============================================================================
# Stage 2: Serve with nginx
# =============================================================================
FROM nginx:1.27-alpine

# Copy built web app
COPY --from=build /app/build/web /usr/share/nginx/html

# Custom nginx config for SPA routing
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 8080

CMD ["nginx", "-g", "daemon off;"]
