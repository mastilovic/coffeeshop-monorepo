# Keycloak Auth Setup

This project uses Keycloak for backend token exchange with API credential login, while browser login/register pages remain public and submit credentials via JSON APIs.

## Local development bootstrap

- `docker-compose` starts Keycloak with `--import-realm`.
- Realm config is stored in `docker/keycloak/realm-coffeeshop.json`.

## Admin console (Docker)

Open **http://localhost:8080/admin** (default master admin: `admin` / `admin` from compose).

### "Loading the Admin UI" forever

**Symptom:** Spinner on "Loading the Admin UI"; Keycloak container logs look fine.

**Cause:** Setting `KC_HOSTNAME=keycloak` makes the admin SPA use `authServerUrl: http://keycloak:8080`, which does not resolve on your Mac. `KC_HOSTNAME_ADMIN_URL` alone is not enough on Keycloak 24 — `authServerUrl` still points at `keycloak`.

**Fix:** Do not set `KC_HOSTNAME` / `KC_HOSTNAME_PORT` in local compose; `start-dev` derives URLs from the request. Browser traffic on `localhost:8080` gets localhost URLs; the backend still calls `http://keycloak:8080` for tokens.

After changing hostname settings:

```bash
cd coffeeshop
docker compose up -d --force-recreate keycloak
```

**Verify:** Hard-refresh the admin page (or use a private window). In DevTools → Network, admin API calls should target `http://localhost:8080`, not `keycloak`.

```bash
curl -s http://localhost:8080/admin/master/console/ | grep -o '"authServerUrl": "[^"]*"'
# Expect: "authServerUrl": "http://localhost:8080"
```

## Required environment variables

Set these values in `.env` (see `.env.example`):

- `KEYCLOAK_SERVER_URL`
- `KEYCLOAK_REALM`
- `KEYCLOAK_CLIENT_ID`
- `KEYCLOAK_CLIENT_SECRET`
- `KEYCLOAK_ADMIN_USER`
- `KEYCLOAK_ADMIN_PASSWORD`
- `AUTH_COOKIE_SAMESITE` (used by legacy browser form/logout routes)
- `AUTH_COOKIE_SECURE` (used by legacy browser form/logout routes)

## Auth endpoint contract

- `GET /login` returns the public login page.
- `GET /register` returns the public registration page.
- `POST /login` is the primary API sign-in endpoint.
- `POST /auth/login` is a backward-compatible alias that delegates to the same login logic.
- Clients must store returned tokens client-side and attach bearer tokens to protected requests.
- `POST /auth/refresh` exchanges a refresh token for a new access token.
- `POST /auth/logout` invalidates a refresh token in Keycloak.


## REST login flow (API clients)

1. Client sends `POST /login` with JSON body:
   `{"email":"user@example.com","password":"secret"}`.
2. App exchanges credentials at Keycloak token endpoint and returns:
   `{"access_token":"...","refresh_token":"...","expires_in":300,"token_type":"Bearer"}`.
3. All protected requests must send `Authorization: Bearer <access_token>`.
   Cookie-only auth without a bearer token should be treated as legacy behavior, not the default integration.
4. Client refreshes tokens with `POST /auth/refresh` and body:
   `{"refresh_token":"<refresh-token>"}`.
5. Client logs out with `POST /auth/logout` and body:
   `{"refresh_token":"<refresh-token>"}`.

### Example requests

```bash
curl -X POST http://localhost:8000/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"secret"}'
```

Backward-compatible alias:

```bash
curl -X POST http://localhost:8000/auth/login \
  -H "Content-Type: application/json" \
  -d '{"email":"user@example.com","password":"secret"}'
```

```bash
curl http://localhost:8000/profile \
  -H "Authorization: Bearer <access_token>" \
  -H "Accept: application/json"
```

```bash
curl -X POST http://localhost:8000/auth/refresh \
  -H "Content-Type: application/json" \
  -d '{"refresh_token":"<refresh_token>"}'
```

## Public registration role policy

- `POST /register` is public and accepts form or JSON clients.
- Self-registration roles are restricted to:
    - `customer`
    - `shop_owner`
- `admin` is not allowed for public registration.
- Unknown or disallowed role values are rejected server-side:
    - invalid enum values fail request validation (`422`)
    - disallowed role policy failures return registration errors (`403`)

## Browser compatibility route (legacy)

- `POST /logout` remains for server-rendered/browser compatibility.
- This route clears auth cookies and logs out of Keycloak using the refresh token stored in cookies.
- If cookies are used, send `x-csrf-token` matching the `csrf_token` cookie.
- New integrations should prefer `POST /auth/logout` with a JSON body:
  `{"refresh_token":"<refresh-token>"}`.

## Docker + Swagger

### Authorize flow (correct order)

1. **Clear** Swagger **Authorize** (or use a fresh browser session) so no stale token is sent globally.
2. Call **`POST /login`** (or `POST /auth/login`) on the backend (e.g. `http://localhost:18080`) **without** a pre-set Bearer token.
3. Copy **`access_token`** only from the JSON response — not `refresh_token`.
4. **Authorize** → paste the token **without** the `Bearer ` prefix (Swagger adds it).
5. Call protected **`POST` / `PUT` / `DELETE`** under `/api/v1/**` or **`GET /profile`**.

### GET vs POST Bearer behavior

| Request | Invalid / stale Bearer |
|---------|-------------------------|
| `GET /api/v1/**` | **200** — Bearer is ignored on public GETs (`PublicEndpointBearerTokenResolver`) |
| `POST` / `PUT` / `DELETE` `/api/v1/**` | **401** — JWT is always validated |
| `GET /profile` | **401** — requires valid authentication |

A token that “works” on `GET /api/v1/user` can still fail on `POST /api/v1/user` if it is expired, wrong type, or has a mismatched `iss`.

### JWT `iss` checklist vs `KEYCLOAK_JWT_ISSUER_URI`

In docker-compose the backend expects:

`KEYCLOAK_JWT_ISSUER_URI=http://keycloak:8080/realms/coffeeshop`

1. Obtain a token via **`POST /login` through the backend** (uses `KEYCLOAK_BASE_URL=http://keycloak:8080`).
2. Decode the JWT payload and confirm **`iss`** equals that URI exactly.
3. Docker compose does not pin `KC_HOSTNAME`; tokens from `POST /login` (backend → `http://keycloak:8080`) use `iss` `http://keycloak:8080/realms/coffeeshop`.
4. Tokens from Keycloak UI at `http://localhost:8080` often have `iss` with `localhost` and will **401** on protected POSTs.

### Common mistakes

| Mistake | Symptom |
|---------|---------|
| Paste `refresh_token` instead of `access_token` | 401 on POST |
| Expired `access_token` (~300s default) | 401 on POST |
| Stale token left in Authorize after earlier session | 401 on POST |
| Paste `Bearer eyJ...` when Swagger already prefixes `Bearer` | Malformed header → 401 |
| JWT `iss` is `http://localhost:8080/...` but backend expects `http://keycloak:8080/...` | 401 on POST; GET may still 200 |
| No `Authorization` header on protected POST | 401 |

## Production checklist

- Set `AUTH_COOKIE_SECURE=true`.
- Use HTTPS for `APP_BASE_URL`.
- Rotate Keycloak client secrets.
- Keep `directAccessGrantsEnabled` enabled only for trusted API clients.
- Restrict Keycloak web origins to trusted domains.
