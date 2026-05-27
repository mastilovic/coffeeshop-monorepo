# Archived: Spring Boot backend (Java)

This directory contains the original **Java 25 / Spring Boot** backend that served `/api/v1`.

It was archived in May 2026 after the Go migration (`coffeeshop-go`) reached parity on `/api/v2`.

## Active stack

| Component | Location |
|-----------|----------|
| API (Go) | `coffeeshop-go/` |
| Frontend | `coffeeshop-frontend/` |
| Local compose | `coffeeshop/docker-compose.yaml` |
| Keycloak realm | `coffeeshop/docker/keycloak/` |

## Running the archived module (reference only)

```bash
cd archive/coffeeshop-java
./gradlew build
```

Requires Postgres and Keycloak as documented in the pre-migration setup.

Do not deploy this module to staging or production.
