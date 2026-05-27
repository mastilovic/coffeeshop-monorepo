# Coffeeshop — local infrastructure

This folder holds **Docker Compose** and **Keycloak** configuration for local development.

The application backend is **Go** (`../coffeeshop-go`). The former Java backend lives in [`../archive/coffeeshop-java`](../archive/coffeeshop-java).

## Quick start

From this directory:

```bash
docker compose up --build
```

| Service | URL |
|---------|-----|
| Frontend | http://localhost:4200 |
| Go API | http://localhost:18080 |
| Keycloak | http://localhost:8080 |
| Postgres (app) | localhost:25432 |

Copy `.env.example` to `.env` to override defaults.
