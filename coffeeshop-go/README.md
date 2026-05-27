# Coffeeshop Go Backend

Primary backend for the coffeeshop application, exposing `/api/v2` endpoints. The former Java Spring Boot backend is archived under `archive/coffeeshop-java/`.

## Architecture

- **Router**: go-chi/chi v5
- **ORM**: GORM (Postgres in prod, SQLite in tests)
- **Auth**: Keycloak JWT validation + token/admin HTTP clients
- **Config**: env-based via caarlos0/env

## API v1 → v2 Endpoint Mapping

All endpoints swap prefix `/api/v1` → `/api/v2`. Request/response JSON, status codes, and query parameters remain identical.

### Auth (`internal/handler/auth.go`)

| Method | v1 Path | v2 Path | Auth |
|--------|---------|---------|------|
| POST | `/api/v1/auth/login` | `/api/v2/auth/login` | Public |
| POST | `/api/v1/auth/register` | `/api/v2/auth/register` | Public |
| POST | `/api/v1/auth/refresh` | `/api/v2/auth/refresh` | Public |
| POST | `/api/v1/auth/logout` | `/api/v2/auth/logout` | Public |

### Profile (`internal/handler/profile.go`)

| Method | v1 Path | v2 Path | Auth |
|--------|---------|---------|------|
| GET | `/api/v1/profile` | `/api/v2/profile` | Required |

### Shop (`internal/handler/shop.go`)

| Method | v1 Path | v2 Path | Auth |
|--------|---------|---------|------|
| GET | `/api/v1/shop` | `/api/v2/shop` | Public (unpaginated) / Required (paginated) |
| GET | `/api/v1/shop/mine` | `/api/v2/shop/mine` | Required |
| GET | `/api/v1/shop/{id}` | `/api/v2/shop/{id}` | Public |
| POST | `/api/v1/shop` | `/api/v2/shop` | Required |
| PUT | `/api/v1/shop/{id}` | `/api/v2/shop/{id}` | Required |
| DELETE | `/api/v1/shop/{id}` | `/api/v2/shop/{id}` | Required |
| POST | `/api/v1/shop/{shopId}/favourite` | `/api/v2/shop/{shopId}/favourite` | Required |
| DELETE | `/api/v1/shop/{shopId}/favourite` | `/api/v2/shop/{shopId}/favourite` | Required |
| GET | `/api/v1/shop/{shopId}/menus` | `/api/v2/shop/{shopId}/menus` | Public |
| POST | `/api/v1/shop/{shopId}/menus` | `/api/v2/shop/{shopId}/menus` | Required |

### Shop Community (`internal/handler/community.go`)

| Method | v1 Path | v2 Path | Auth |
|--------|---------|---------|------|
| GET | `/api/v1/shop/{shopId}/community/posts` | `/api/v2/shop/{shopId}/community/posts` | Public |
| GET | `/api/v1/shop/{shopId}/community/members` | `/api/v2/shop/{shopId}/community/members` | Public |
| POST | `/api/v1/shop/{shopId}/community/announcements` | `/api/v2/shop/{shopId}/community/announcements` | Required |
| DELETE | `/api/v1/shop/{shopId}/community/posts/{postId}` | `/api/v2/shop/{shopId}/community/posts/{postId}` | Required |

### Event (`internal/handler/event.go`)

| Method | v1 Path | v2 Path | Auth |
|--------|---------|---------|------|
| GET | `/api/v1/event` | `/api/v2/event` | Public |
| GET | `/api/v1/event/{eventId}` | `/api/v2/event/{eventId}` | Public |
| POST | `/api/v1/event` | `/api/v2/event` | Required |
| PUT | `/api/v1/event/{eventId}` | `/api/v2/event/{eventId}` | Required |
| DELETE | `/api/v1/event/{eventId}` | `/api/v2/event/{eventId}` | Required |

### User (`internal/handler/user.go`)

| Method | v1 Path | v2 Path | Auth |
|--------|---------|---------|------|
| GET | `/api/v1/user` | `/api/v2/user` | Public |
| GET | `/api/v1/user/{id}` | `/api/v2/user/{id}` | Public |
| POST | `/api/v1/user` | `/api/v2/user` | Required |
| PUT | `/api/v1/user/{id}` | `/api/v2/user/{id}` | Required |
| DELETE | `/api/v1/user/{id}` | `/api/v2/user/{id}` | Required |

### Review (`internal/handler/review.go`)

| Method | v1 Path | v2 Path | Auth |
|--------|---------|---------|------|
| GET | `/api/v1/review` | `/api/v2/review` | Public |
| GET | `/api/v1/review/{id}` | `/api/v2/review/{id}` | Public |
| POST | `/api/v1/review` | `/api/v2/review` | Required |
| PUT | `/api/v1/review/{id}` | `/api/v2/review/{id}` | Required |
| DELETE | `/api/v1/review/{id}` | `/api/v2/review/{id}` | Required |
| GET | `/api/v1/review/{reviewId}/comments` | `/api/v2/review/{reviewId}/comments` | Public |
| POST | `/api/v1/review/{reviewId}/comments` | `/api/v2/review/{reviewId}/comments` | Required |

### Reservation (`internal/handler/reservation.go`)

| Method | v1 Path | v2 Path | Auth |
|--------|---------|---------|------|
| GET | `/api/v1/reservation` | `/api/v2/reservation` | Public |
| GET | `/api/v1/reservation/{id}` | `/api/v2/reservation/{id}` | Public |
| POST | `/api/v1/reservation` | `/api/v2/reservation` | Required |
| PUT | `/api/v1/reservation/{id}` | `/api/v2/reservation/{id}` | Required |
| DELETE | `/api/v1/reservation/{id}` | `/api/v2/reservation/{id}` | Required |

### Reservation Request (`internal/handler/reservation_request.go`)

| Method | v1 Path | v2 Path | Auth |
|--------|---------|---------|------|
| GET | `/api/v1/reservation-request` | `/api/v2/reservation-request` | Required |
| POST | `/api/v1/reservation-request` | `/api/v2/reservation-request` | Required |
| POST | `/api/v1/reservation-request/{id}/accept` | `/api/v2/reservation-request/{id}/accept` | Required |
| POST | `/api/v1/reservation-request/{id}/deny` | `/api/v2/reservation-request/{id}/deny` | Required |

### Menu (`internal/handler/menu.go`)

| Method | v1 Path | v2 Path | Auth |
|--------|---------|---------|------|
| GET | `/api/v1/menu` | `/api/v2/menu` | Public |
| GET | `/api/v1/menu/{id}` | `/api/v2/menu/{id}` | Public |
| POST | `/api/v1/menu` | `/api/v2/menu` | Required |
| PUT | `/api/v1/menu/{id}` | `/api/v2/menu/{id}` | Required |
| DELETE | `/api/v1/menu/{id}` | `/api/v2/menu/{id}` | Required |

### Menu Item (`internal/handler/menu_item.go`)

| Method | v1 Path | v2 Path | Auth |
|--------|---------|---------|------|
| GET | `/api/v1/menu-item` | `/api/v2/menu-item` | Public |
| GET | `/api/v1/menu-item/{id}` | `/api/v2/menu-item/{id}` | Public |
| POST | `/api/v1/menu-item` | `/api/v2/menu-item` | Required |
| PUT | `/api/v1/menu-item/{id}` | `/api/v2/menu-item/{id}` | Required |
| DELETE | `/api/v1/menu-item/{id}` | `/api/v2/menu-item/{id}` | Required |

### Table (`internal/handler/table.go`)

| Method | v1 Path | v2 Path | Auth |
|--------|---------|---------|------|
| GET | `/api/v1/table` | `/api/v2/table` | Public |
| GET | `/api/v1/table/{id}` | `/api/v2/table/{id}` | Public |
| POST | `/api/v1/table` | `/api/v2/table` | Required |
| PUT | `/api/v1/table/{id}` | `/api/v2/table/{id}` | Required |
| DELETE | `/api/v1/table/{id}` | `/api/v2/table/{id}` | Required |

### Contact (`internal/handler/contact.go`)

| Method | v1 Path | v2 Path | Auth |
|--------|---------|---------|------|
| GET | `/api/v1/contact` | `/api/v2/contact` | Public |
| GET | `/api/v1/contact/{id}` | `/api/v2/contact/{id}` | Public |
| POST | `/api/v1/contact` | `/api/v2/contact` | Required |
| PUT | `/api/v1/contact/{id}` | `/api/v2/contact/{id}` | Required |
| DELETE | `/api/v1/contact/{id}` | `/api/v2/contact/{id}` | Required |

### Role (`internal/handler/role.go`)

| Method | v1 Path | v2 Path | Auth |
|--------|---------|---------|------|
| GET | `/api/v1/role` | `/api/v2/role` | Public |
| GET | `/api/v1/role/{id}` | `/api/v2/role/{id}` | Public |
| POST | `/api/v1/role` | `/api/v2/role` | Required |
| PUT | `/api/v1/role/{id}` | `/api/v2/role/{id}` | Required |
| DELETE | `/api/v1/role/{id}` | `/api/v2/role/{id}` | Required |

### Loyalty Plan (`internal/handler/loyalty_plan.go`)

| Method | v1 Path | v2 Path | Auth |
|--------|---------|---------|------|
| GET | `/api/v1/loyalty-plan` | `/api/v2/loyalty-plan` | Public |
| GET | `/api/v1/loyalty-plan/{id}` | `/api/v2/loyalty-plan/{id}` | Public |
| POST | `/api/v1/loyalty-plan` | `/api/v2/loyalty-plan` | Required |
| PUT | `/api/v1/loyalty-plan/{id}` | `/api/v2/loyalty-plan/{id}` | Required |
| DELETE | `/api/v1/loyalty-plan/{id}` | `/api/v2/loyalty-plan/{id}` | Required |

### Reference (`internal/handler/reference.go`)

| Method | v1 Path | v2 Path | Auth |
|--------|---------|---------|------|
| GET | `/api/v1/reference/serbia-cities` | `/api/v2/reference/serbia-cities` | Public |

---

## Enums

| Enum | Values |
|------|--------|
| `UserType` | `CUSTOMER`, `SHOP_OWNER`, `ADMIN` |
| `UserShopRelationshipType` | `OWNER`, `FAVOURITE` |
| `ReservationStatus` | `PENDING`, `ACCEPTED`, `DENIED` |
| `MenuItemType` | `FOOD`, `DRINK`, `DESSERT`, `OTHER` |
| `CommunityPostType` | `POST`, `ANNOUNCEMENT` |
| `RoleType` | `USER`, `ADMIN`, `SHOP_OWNER` |
| `LoyaltyPlanType` | `BASIC`, `PREMIUM`, `VIP` |

---

## Pagination

Paginated responses use:

```json
{
  "content": [],
  "page": 0,
  "size": 10,
  "totalElements": 42,
  "totalPages": 5
}
```

Allowed page sizes: `10`, `25`, `50`

Query parameters: `?page=0&size=10&q=search+term`

When `page` param is absent, endpoints return a flat list (no pagination wrapper).

---

## Error Responses

All errors return:

```json
{"message": "description of the error"}
```

| HTTP Status | Condition |
|-------------|-----------|
| 400 | Bad request / illegal argument |
| 401 | Authentication required or failed |
| 404 | Resource not found |
| 422 | Validation failed (first field error message) |

---

## Running

```bash
# Local development
cd coffeeshop-go
go run ./cmd/api

# Docker (from coffeeshop/)
docker compose up backend

# Tests
go test ./...
```

## Environment Variables

| Variable | Default | Description |
|----------|---------|-------------|
| `PORT` | `8080` | Server listen port |
| `DATABASE_URL` | `postgres://coffeeshop:coffeeshop_dev_password@localhost:25432/coffeeshop?sslmode=disable` | PostgreSQL connection string |
| `KEYCLOAK_BASE_URL` | `http://localhost:8080` | Keycloak server URL |
| `KEYCLOAK_REALM` | `coffeeshop` | Keycloak realm name |
| `KEYCLOAK_BACKEND_CLIENT_ID` | `coffeeshop-backend` | OAuth2 client ID |
| `KEYCLOAK_BACKEND_CLIENT_SECRET` | `local-backend-secret` | OAuth2 client secret |
| `KEYCLOAK_JWT_ISSUER_URI` | `http://localhost:8080/realms/coffeeshop` | JWT issuer URI for token validation |
| `KEYCLOAK_ADMIN_USER` | `admin` | Keycloak admin username |
| `KEYCLOAK_ADMIN_PASSWORD` | `admin` | Keycloak admin password |
| `CORS_ALLOWED_ORIGINS` | `http://localhost:4200` | Comma-separated allowed origins |
| `RUN_MIGRATIONS` | `false` | Run `golang-migrate` on startup |
| `MIGRATIONS_PATH` | `migrations` | Path to SQL migration files |
| `SENTRY_DSN` | _(empty)_ | Sentry DSN (optional) |

## Database migrations

Schema is managed with [golang-migrate](https://github.com/golang-migrate/migrate) in `migrations/`. The initial migration uses `CREATE TABLE IF NOT EXISTS` so it is safe on databases already created by Hibernate.

```bash
# Enable on startup (Docker Compose sets this automatically)
RUN_MIGRATIONS=true MIGRATIONS_PATH=migrations go run ./cmd/api
```
