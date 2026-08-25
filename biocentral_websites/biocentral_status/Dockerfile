# Build stage
FROM ghcr.io/cirruslabs/flutter:stable AS build
WORKDIR /app
COPY . .
COPY ../../biocentral_api/dart ./biocentral_api/dart
RUN flutter build web --release

# Serve stage
FROM nginx:alpine
COPY --from=build /app/build/web /usr/share/nginx/html
EXPOSE 80
