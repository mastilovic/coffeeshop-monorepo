# syntax=docker/dockerfile:1

FROM node:22-alpine AS build
WORKDIR /app

COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm \
    npm ci

COPY angular.json tsconfig.json tsconfig.app.json ./
COPY public public
COPY src src

RUN --mount=type=cache,target=/root/.npm \
    --mount=type=cache,target=/app/.angular \
    npm run build:docker

FROM nginx:alpine
COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY --from=build /app/dist/coffeeshop-frontend/browser /usr/share/nginx/html
EXPOSE 80
