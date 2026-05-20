# CoffeeShop Frontend — Reimplementation Guide

This document describes everything needed to **rebuild the frontend SPA** against the **Spring Boot backend** in `coffeeshop/src/main/java/com/coffeeshop/coffeeshop`. All navigation is client-side; entity data comes from REST JSON APIs.

---

## Table of Contents

1. [SPA Requirements](#1-spa-requirements)
2. [Technology Stack](#2-technology-stack)
3. [Project Structure](#3-project-structure)
4. [Application Bootstrap](#4-application-bootstrap)
5. [Routing](#5-routing)
6. [Authentication](#6-authentication)
7. [HTTP & API Layer](#7-http--api-layer)
8. [Data Models](#8-data-models)
9. [Feature Specifications](#9-feature-specifications)
10. [UI / Design System](#10-ui--design-system)
11. [Authorization Rules](#11-authorization-rules)
12. [Backend Integration Notes](#12-backend-integration-notes)
13. [Build, Run & Deploy (SPA)](#13-build-run--deploy-spa)
14. [Testing](#14-testing)
15. [Known Gaps & Notes](#15-known-gaps--notes)
16. [API Endpoint Reference](#16-api-endpoint-reference)

---

## 1. SPA Requirements

### What “SPA” means for this project

| Requirement | Implementation |
|-------------|----------------|
| Single HTML shell | `index.html` loads once; content swaps via `<router-outlet>` |
| Client-side routing | `@angular/router` — no server round-trips for route changes |
| Lazy-loaded views | Route `loadComponent` dynamic imports per feature |
| API-driven data | All entity data from REST JSON APIs via `HttpClient` |
| No multi-page server templates | No per-route `.html` files served by the backend |

### Root component

The app root is minimal: only a router outlet.

```typescript
@Component({
  selector: 'app-root',
  template: `<router-outlet />`,
})
export class App {}
```

### Layout shell

Authenticated/main UI uses a **persistent layout** (`LayoutComponent`) with sidebar + header. Child routes render inside the layout’s nested `<router-outlet>`.

### Auth routes (outside layout)

`/login` and `/register` are **full-screen** routes without the sidebar layout.

### Deep linking & static hosting

For a **pure SPA** deployed to static storage (S3, Netlify, nginx):

1. Configure the host to serve `index.html` for all non-file paths (fallback).
2. Use **PathLocationStrategy** (default) with `<base href="/">` in `index.html`.
3. Alternatively use **HashLocationStrategy** (`#/dashboard`) if the host cannot rewrite URLs.

### SSR (optional to remove)

If `angular.json` enables Angular SSR, remove `server`, `ssr`, and `outputMode` for a classic SPA-only deploy. The spec below assumes **client-only SPA**.

---

## 2. Technology Stack

| Layer | Choice | Version (current) |
|-------|--------|-------------------|
| Framework | Angular (standalone components) | 21.x |
| Language | TypeScript (strict) | 5.9.x |
| Routing | `@angular/router` | 21.x |
| HTTP | `@angular/common/http` with `withFetch()` | 21.x |
| Forms | Reactive Forms (`@angular/forms`) | 21.x |
| State | Angular **signals** + `computed` | — |
| Change detection | `ChangeDetectionStrategy.OnPush` on all components | — |
| Styling | Component-scoped inline `styles` + global `styles.css` | No CSS framework |
| Tests | Vitest via `@angular/build:unit-test` | 4.x |
| Package manager | npm | 11.x |

**Not used:** NgRx, Angular Material, Tailwind, separate `.html` template files (inline templates only).

---

## 3. Project Structure

```
src/
├── main.ts
├── index.html
├── styles.css
├── environments/
│   ├── environment.ts
│   └── environment.prod.ts
└── app/
    ├── app.ts
    ├── app.config.ts
    ├── app.routes.ts
    ├── models/
    ├── services/
    ├── shared/layout/
    └── features/
        ├── auth/                 # login, register
        ├── dashboard/
        ├── menu/                 # global menu items CRUD
        ├── events/
        ├── reservations/         # reservation requests + confirmed reservations
        ├── users/
        ├── shops/                # was "tenants" in older templates
        ├── shop-details/         # per-shop: users, menu, tables, reservations
        ├── profile/
        └── reviews/              # optional feature (API exists)
```

**Reference API contract:**

- Live OpenAPI UI: `http://localhost:8080/swagger/index.html` (when backend is running)
- Java DTOs: `coffeeshop/src/main/java/com/coffeeshop/coffeeshop/model/dto/`
- Controllers: `coffeeshop/src/main/java/com/coffeeshop/coffeeshop/controller/` and `auth/`

---

## 4. Application Bootstrap

### `main.ts`

```typescript
bootstrapApplication(App, appConfig);
```

### `app.config.ts` providers

```typescript
export const appConfig: ApplicationConfig = {
  providers: [
    provideBrowserGlobalErrorListeners(),
    provideRouter(routes),
    provideHttpClient(withFetch(), withInterceptors([authInterceptor])),
  ],
};
```

### Environment

```typescript
// environment.ts (development)
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8080',
};

// environment.prod.ts
export const environment = {
  production: true,
  apiUrl: 'https://api.coffeeshop.com',
};
```

- **Auth endpoints** are at the API root: `` `${environment.apiUrl}/login` ``, `` `${environment.apiUrl}/register` ``, etc.
- **Resource endpoints** use versioned paths: `` `${environment.apiUrl}/api/v1/...` ``

---

## 5. Routing

### Route table

| Path | Component | Layout | Lazy |
|------|-----------|--------|------|
| `/login` | `LoginComponent` | No | Yes |
| `/register` | `RegisterComponent` | No | Yes |
| `/` → redirect | → `/dashboard` | — | — |
| `/dashboard` | `DashboardComponent` | Yes | Yes |
| `/menu` | `MenuComponent` | Yes | Yes |
| `/events` | `EventsComponent` | Yes | Yes |
| `/reservations` | `ReservationsComponent` | Yes | Yes |
| `/users` | `UsersComponent` | Yes | Yes |
| `/shops` | `ShopsComponent` | Yes | Yes |
| `/shops/:id` | `ShopDetailsComponent` | Yes | Yes |
| `/profile` | `ProfileComponent` | Yes | Yes |
| `**` | redirect → `/dashboard` | — | — |

### Sidebar navigation labels

| Route | Label |
|-------|-------|
| `/dashboard` | Dashboard |
| `/menu` | Menu |
| `/events` | Events |
| `/reservations` | My Reservations |
| `/users` | Users |
| `/shops` | Shops |

Profile is accessed from the **header dropdown** (`/profile`), not the sidebar.

### Auth guard

Add `canActivate: [authGuard]` on the layout route (and/or children) so unauthenticated users are redirected to `/login`. Mutating API calls require a JWT even though many `GET /api/v1/**` routes are publicly readable.

---

## 6. Authentication

The backend uses **Keycloak** (OAuth2 resource server). Tokens are issued by the backend auth layer, not stored in custom JWT logic on the server.

### Flow

1. **Register:** `POST /register` with `{ name, email, password, role }` where `role` is `customer` or `shop_owner` (not `admin`).
2. **Response:** `201` + `UserResponseDto` — registration does **not** return tokens; user must log in.
3. **Login:** `POST /login` or `POST /auth/login` with `{ email, password }`.
4. **Response:** Keycloak-style token bundle:

```json
{
  "access_token": "...",
  "refresh_token": "...",
  "expires_in": 300,
  "token_type": "Bearer"
}
```

5. **Storage:** persist `access_token` and `refresh_token` (e.g. `localStorage` keys `coffeeshop_access_token`, `coffeeshop_refresh_token`).
6. **Subsequent requests:** `Authorization: Bearer <access_token>` via `authInterceptor`.
7. **Refresh:** `POST /auth/refresh` with `{ "refresh_token": "..." }` → new `TokenResponse`.
8. **Logout:** `POST /auth/logout` with `{ "refresh_token": "..." }` → `204 No Content`.

### Token decoding (client-side)

Decode the JWT access token payload for UI state:

| Claim | Usage |
|-------|--------|
| `sub` | Keycloak subject (map to app user via profile or user list) |
| `email` or `preferred_username` | Display email |
| `realm_access.roles` | Realm roles (`customer`, `shop_owner`, `admin`, …) |
| `exp` | Expiry |

Backend maps realm roles to Spring authorities as `ROLE_<ROLE>` (uppercase, hyphens → underscores), e.g. `ROLE_CUSTOMER`, `ROLE_SHOP_OWNER`, `ROLE_ADMIN`.

Exposed signals/computed (suggested):

- `isAuthenticated`, `accessToken`, `refreshToken`, `currentUserEmail`, `realmRoles`, `isAdmin` (`admin` in roles)

### Current user profile

`GET /profile` (authenticated) returns full `UserResponseDto` for the JWT subject — use this instead of a `/api/v1/user/self` route (which does not exist).

### Logout

Clear tokens from storage, call `/auth/logout` with refresh token, reset signals, navigate to `/login`.

---

## 7. HTTP & API Layer

### Service pattern

Each domain has an `@Injectable({ providedIn: 'root' })` service:

- Injects `HttpClient`
- Uses `environment.apiUrl`
- Returns `Observable<T>`
- Errors: backend returns `{ "message": "..." }` (`ErrorResponse` record)

### Services map

| Service | Base path | Notes |
|---------|-----------|-------|
| `AuthService` | `/login`, `/register`, `/auth/login`, `/auth/refresh`, `/auth/logout` | Root paths, not under `/api/v1` |
| `ProfileService` | `/profile` | Authenticated current user |
| `UserService` | `/api/v1/user` | |
| `ShopService` | `/api/v1/shop` | Replaces legacy “Tenant” |
| `EventService` | `/api/v1/event` | |
| `ReservationService` | `/api/v1/reservation` | Confirmed reservations (table assignment) |
| `ReservationRequestService` | `/api/v1/reservation-request` | Request → accept/deny workflow |
| `MenuService` | `/api/v1/menu` | Create body is empty `{}` |
| `MenuItemService` | `/api/v1/menu-item` | |
| `TableService` | `/api/v1/table` | |
| `ReviewService` | `/api/v1/review` | |
| `ContactService` | `/api/v1/contact` | |
| `RoleService` | `/api/v1/role` | App roles (not Keycloak realm roles) |
| `LoyaltyPlanService` | `/api/v1/loyalty-plan` | Linked on shop, not per-user “card” |

All versioned resources use **kebab-case** paths under `/api/v1/`.

### Security (reads vs writes)

From `SecurityConfiguration`:

- **Public:** `POST /login`, `/register`, `/auth/login`, `/auth/refresh`, `/auth/logout`
- **Public:** all `GET /api/v1/**`
- **Authenticated:** `GET /profile`, all mutating methods on resources (`POST`/`PUT`/`DELETE` on `/api/v1/**`), reservation-request endpoints

Plan UI so browsing works without login, but create/edit/delete and reservation requests require a token.

### Interceptor

```typescript
export const authInterceptor: HttpInterceptorFn = (req, next) => {
  const token = authService.accessToken();
  if (token) {
    return next(req.clone({
      setHeaders: { Authorization: `Bearer ${token}` },
    }));
  }
  return next(req);
};
```

---

## 8. Data Models

Align TypeScript interfaces with Java DTOs under `model/dto/`. IDs are **`string` (UUID)** in JSON.

### User & auth

**`UserResponseDto`**

```typescript
interface UserResponseDto {
  id: string;
  name: string;
  email: string;
  userType: 'CUSTOMER' | 'SHOP_OWNER' | 'ADMIN';
  roles: RoleResponseDto[];
  favouriteShops: ShopSummaryDto[];
  reviews: ReviewResponseDto[];
  reservations: ReservationResponseDto[];
}
```

**`RegisterRequest`:** `{ name, email, password, role: 'customer' | 'shop_owner' }`

**`LoginRequest`:** `{ email, password }`

**`TokenResponse`:** `{ access_token, refresh_token, expires_in, token_type }`

**`UserCreateRequest` / `UserUpdateRequest`:** `name`, `email`, optional `password`, `userType`, `roleIds`; update also supports `favouriteShopIds`.

There is **no** `username`, `firstName`/`lastName`, or `points` field on the backend user model.

### Shop (replaces Tenant)

**`ShopResponseDto`:** `id`, `name`, `address`, `phoneNumber`, `email`, `createdBy` (`UserSummaryDto`), `users[]`, nested `menu`, `loyaltyPlan`, `events[]`, `tables[]`, `reviews[]`, `contacts[]`

**`ShopCreateRequest`:** `name`, `address`, `phoneNumber`, `email`, `createdByUserId`, optional `menuId`, optional `loyaltyPlanId`

**`ShopSummaryDto`:** `id`, `name`, `address`, `phoneNumber`, `email`

There is **no** `TenantType` enum, `my-tenants`, or tenant-membership CRUD API. Shop staff are the `users` collection on the shop entity (many-to-many); no dedicated “add member” endpoint in the current API.

### Event

**`EventResponseDto`:** `eventId` (string), `eventName`, `eventDate` (string), `description`, `shopId`

**`EventCreateRequest` / `EventUpdateRequest`:** same fields (no separate start/end datetime).

### Reservation

**`ReservationResponseDto`:** `id`, `user` (`UserSummaryDto`), `shop` (`ShopSummaryDto`), `minPartySize`, `maxPartySize`, `reservationRequestId`, `table` (`TableSummaryDto`)

**`ReservationCreateRequest` / `ReservationUpdateRequest`:** `{ userId, tableId }` — assigns a table to a user; shop is implied via the table.

**`ReservationRequestResponseDto`:** `id`, `user`, `shop`, `minPartySize`, `maxPartySize`, `status` (`PENDING` | `ACCEPTED` | `DENIED`), `reservationId`

**`ReservationRequestCreateRequest`:** `{ userId, shopId, minPartySize, maxPartySize? }`

**`ReservationAcceptRequest`:** `{ tableId }` for `POST /api/v1/reservation-request/{id}/accept`

Customer flow: create **request** → shop owner **accepts** (with table) or **denies** → optional confirmed **reservation**.

### Menu

**`MenuResponseDto`:** `id`, `items[]` (no name/description on menu itself)

**`MenuItemResponseDto`:** `id`, `name`, `description`, `price`, `priceCurrency`, `imageUrl`, `menuId`

**`MenuCreateRequest`:** empty object `{}`

### Table

**`TableResponseDto`:** `id`, `number`, `capacity`, `shopId`, `reservations[]`

### Review

**`ReviewResponseDto`:** `id`, `title`, `description`, `rating`, `reviewDate` (ISO instant), `user`, `shop`

### Role & loyalty

**`RoleResponseDto`:** `id`, `name`, `type` (`USER` | `ADMIN` | `SHOP_OWNER`)

**`LoyaltyPlanResponseDto`:** `id`, `name`, `description`, `type` (`LoyaltyPlanType` enum — currently empty in backend)

### Contact

**`ContactResponseDto`:** `id`, `shopId` (minimal)

---

## 9. Feature Specifications

### 9.1 Login (`/login`)

- Reactive form: email, password
- `POST /login` → store `access_token` + `refresh_token`
- On success: navigate to `/dashboard`
- On `401`: show error from `{ message }` body
- Link to `/register`

### 9.2 Register (`/register`)

- Fields: **name**, email, password, role select (`customer` | `shop_owner`)
- `POST /register` → show success; link to login (no auto-login)
- Handle `409` (email exists), `403` (admin role), validation errors

### 9.3 Dashboard (`/dashboard`)

- Stat cards: shop count, menu item count, event count, pending reservation requests (optional)
- Loads: `GET /api/v1/shop`, `GET /api/v1/event`, `GET /api/v1/menu-item`

### 9.4 Menu (`/menu`)

- Global menu items: `GET /api/v1/menu-item`, CRUD on `/api/v1/menu-item`
- Form: `name`, `description`, `price`, `priceCurrency`, `imageUrl`, `menuId` (required to attach to a menu)
- Menus themselves are created with `POST /api/v1/menu` (empty body); link menu to shop via `ShopCreateRequest.menuId` / update

### 9.5 Events (`/events`)

- Table: `eventName`, shop name (resolve `shopId` via shops list), `eventDate`, description
- Form: `eventName`, `eventDate`, `description`, shop select (`shopId`)
- CRUD via `/api/v1/event` (`eventId` in path for get/update/delete)

### 9.6 My Reservations (`/reservations`)

Two sub-flows recommended:

1. **Requests (customer):** `POST /api/v1/reservation-request` with current user’s `userId`, target `shopId`, party size
2. **Confirmed:** `GET /api/v1/reservation`, filter where `reservation.user.id === currentUserId` (from `/profile`)

Shop owners: list requests for their shops (filter client-side on `shop.id`), call accept/deny endpoints.

There is **no** `reservationDate` / `numberOfGuests` / `specialRequests` on the backend model.

### 9.7 Users (`/users`)

- `GET /api/v1/user` — list all users
- Display: `name`, `email`, `userType`, roles
- Edit own row: `PUT /api/v1/user/{id}` when `id` matches profile user
- Delete: restrict to admin realm role (`ROLE_ADMIN`)
- No loyalty points column (use shop `loyaltyPlan` instead)

### 9.8 Shops (`/shops`)

- Card grid from `GET /api/v1/shop`
- Click → `/shops/:id`
- Create: `POST /api/v1/shop` with `createdByUserId` from profile
- Edit/delete: authenticated; gate UI by `createdBy.id` or `SHOP_OWNER` / `ADMIN` roles
- No tenant-type badge (backend has no shop type enum)

### 9.9 Shop Details (`/shops/:id`)

Load `GET /api/v1/shop/{id}` once; nested DTO includes related data.

Suggested tabs:

| Tab | Data source | Actions |
|-----|-------------|---------|
| **Users** | `shop.users` | Read-only unless backend adds membership API |
| **Menu** | `shop.menu` + items | CRUD menu items via `/api/v1/menu-item` with `menuId` |
| **Tables** | `shop.tables` | CRUD via `/api/v1/table` |
| **Reservations** | Filter `GET /api/v1/reservation` by `shop.id` | Accept requests via reservation-request API |
| **Events** | `shop.events` or global event list filtered by `shopId` | |
| **Reviews** | `shop.reviews` | Optional CRUD via `/api/v1/review` |

### 9.10 Profile (`/profile`)

- `GET /profile` → `UserResponseDto`
- View: `name`, `email`, `userType`, roles, favourite shops
- Edit: `PUT /api/v1/user/{id}` with `UserUpdateRequest` (`name`, `email`, `favouriteShopIds`, …)

### 9.11 Layout chrome

- Collapsible sidebar, profile dropdown, dark theme (see §10)

---

## 10. UI / Design System

### Color palette

| Token | Hex | Usage |
|-------|-----|-------|
| Background | `#121212` | Page body |
| Surface | `#1a1a2e` | Cards, sidebar, header |
| Surface elevated | `#16213e` | Inputs, hover rows |
| Border | `#2a2a3e` | Dividers |
| Text primary | `#e0e0e0` / `#fff` | Body / headings |
| Text muted | `#888`, `#aaa` | Labels, secondary |
| Accent | `#d4a574` | Brand, links, active nav, primary buttons |
| Danger | `#c0392b` | Delete buttons |
| Success | `#4caf50` | Success messages |

### Typography

System stack: `-apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif`

### Recurring CSS classes

- `.page`, `.page-header`, `.page-title`
- `.form-card`, `.form-group`, `.form-input`, `.form-row`, `.form-actions`
- `.btn`, `.btn-primary`, `.btn-secondary`, `.btn-danger`, `.btn-sm`, `.btn-block`
- `.data-table`, `.table-container`, `.card-grid`, `.card`
- `.loading`, `.empty-state`, `.badge`

### UX patterns

- Signal-driven `showForm` toggles
- `confirm()` for deletes
- ISO date strings for API; `datetime-local` only where the backend stores a single date string (`eventDate`)

---

## 11. Authorization Rules

| Action | Rule |
|--------|------|
| Browse lists (`GET /api/v1/**`) | No token required (backend policy) |
| Create shop / mutate resources | Valid JWT required |
| Edit own user | `profile.id === user.id` |
| Delete user | Keycloak realm role `admin` |
| Edit/delete shop | Shop `createdBy.id` matches user, or `SHOP_OWNER` / `ADMIN` |
| Reservation request accept/deny | Shop owner for that shop (app-level check; backend enforces authenticated) |
| My reservations list | Filter by `user.id` from profile |

Resolve the app user id via `GET /profile` after login (JWT `sub` is Keycloak subject; app `User.id` is a separate UUID in the database).

---

## 12. Backend Integration Notes

### Checklist when wiring the SPA

1. Set `environment.apiUrl` to `http://localhost:8080` (default `server.port` in `application.yaml`).
2. Use **snake_case** token fields from Keycloak (`access_token`, `refresh_token`).
3. Implement token refresh before expiry using `/auth/refresh`.
4. Replace legacy **Tenant** UI copy and routes with **Shop** (`/api/v1/shop`).
5. Map register/login DTOs to `RegisterRequest` / `LoginRequest` (name + role, not username).
6. Use `GET /profile` for the current user (not `/api/v1/user/self`).
7. Implement **reservation request** flow; do not assume date/guest-count reservation fields.
8. Use **UUID** strings for all ids in paths and bodies.
9. Import OpenAPI from `http://localhost:8080/v3/api-docs` when generating clients.
10. Ensure CORS: backend has `@CrossOrigin(origins = "*")` on controllers; SPA dev server typically `http://localhost:4200`.

### Keycloak (local)

Backend expects JWT issuer `KEYCLOAK_JWT_ISSUER_URI` (default `http://localhost:8080/realms/coffeeshop`). Registration creates users in Keycloak and the app database.

### Minimal contract summary

| Capability | Endpoints |
|------------|-----------|
| Auth | `/login`, `/register`, `/auth/refresh`, `/auth/logout` |
| Current user | `GET /profile` |
| Users | `/api/v1/user` CRUD |
| Shops | `/api/v1/shop` CRUD + nested data on GET by id |
| Events | `/api/v1/event` CRUD |
| Reservations | `/api/v1/reservation` + `/api/v1/reservation-request` |
| Menus / items | `/api/v1/menu`, `/api/v1/menu-item` |
| Tables, reviews, contacts, roles, loyalty | respective `/api/v1/*` resources |

---

## 13. Build, Run & Deploy (SPA)

### Development

```bash
# Terminal 1 — backend (from coffeeshop/)
./mvnw spring-boot:run

# Terminal 2 — frontend
npm install
ng serve
# http://localhost:4200  →  API http://localhost:8080
```

### Production build

```bash
ng build --configuration production
# Output: dist/<app>/browser/
```

### Static hosting nginx example

```nginx
location / {
  try_files $uri $uri/ /index.html;
}
```

---

## 14. Testing

- Runner: **Vitest** (`ng test`)
- Test services with `HttpClientTestingModule` and mock `TokenResponse` / `UserResponseDto` shapes
- Cover: auth interceptor, token refresh, reservation-request accept flow, profile-based user id resolution

---

## 15. Known Gaps & Notes

| Item | Status |
|------|--------|
| Legacy .NET paths (`/api/Tenant`, `/api/users/self`) | **Removed** — use Spring paths in §16 |
| Shop staff management | No dedicated add/remove member API; `users` on shop DTO only |
| `GET /api/v1/**` public | Mutations still need JWT; UI may show edit buttons to anonymous users if not gated |
| Reservation model differs from old template | No `reservationDate` / `specialRequests`; use request + table assignment |
| Menu entity | No name/description; only `id` + items |
| `LoyaltyPlanType` enum | Empty in backend |
| Register → login | Two-step; no token on register |
| JWT `sub` vs `User.id` | May differ; always use `/profile` for app user uuid |
| `api-docs.json` in frontend folder | May be stale; prefer live `/v3/api-docs` from running backend |

---

## 16. API Endpoint Reference

Base: `{apiUrl}` (default `http://localhost:8080`).

### Auth (root paths)

| Method | Path | Body | Response |
|--------|------|------|----------|
| POST | `/register` | `RegisterRequest` | `201` `UserResponseDto` |
| POST | `/login` | `LoginRequest` | `TokenResponse` |
| POST | `/auth/login` | `LoginRequest` | `TokenResponse` (alias) |
| POST | `/auth/refresh` | `{ "refresh_token": "..." }` | `TokenResponse` |
| POST | `/auth/logout` | `{ "refresh_token": "..." }` | `204` |
| GET | `/profile` | — | `UserResponseDto` (auth required) |

### Users — `/api/v1/user`

| Method | Path | Auth for mutate |
|--------|------|-----------------|
| GET | `/api/v1/user` | — |
| GET | `/api/v1/user/{id}` | — |
| POST | `/api/v1/user` | Yes |
| PUT | `/api/v1/user/{id}` | Yes |
| DELETE | `/api/v1/user/{id}` | Yes |

### Shops — `/api/v1/shop`

| Method | Path |
|--------|------|
| GET | `/api/v1/shop` |
| GET | `/api/v1/shop/{id}` |
| POST | `/api/v1/shop` |
| PUT | `/api/v1/shop/{id}` |
| DELETE | `/api/v1/shop/{id}` |

### Events — `/api/v1/event`

| Method | Path |
|--------|------|
| GET | `/api/v1/event` |
| GET | `/api/v1/event/{eventId}` |
| POST | `/api/v1/event` |
| PUT | `/api/v1/event/{eventId}` |
| DELETE | `/api/v1/event/{eventId}` |

### Reservations — `/api/v1/reservation`

| Method | Path |
|--------|------|
| GET | `/api/v1/reservation` |
| GET | `/api/v1/reservation/{id}` |
| POST | `/api/v1/reservation` |
| PUT | `/api/v1/reservation/{id}` |
| DELETE | `/api/v1/reservation/{id}` |

### Reservation requests — `/api/v1/reservation-request`

| Method | Path | Body |
|--------|------|------|
| POST | `/api/v1/reservation-request` | `ReservationRequestCreateRequest` |
| POST | `/api/v1/reservation-request/{id}/accept` | `ReservationAcceptRequest` |
| POST | `/api/v1/reservation-request/{id}/deny` | — |

### Menus — `/api/v1/menu`

| Method | Path |
|--------|------|
| GET | `/api/v1/menu` |
| GET | `/api/v1/menu/{id}` |
| POST | `/api/v1/menu` |
| PUT | `/api/v1/menu/{id}` |
| DELETE | `/api/v1/menu/{id}` |

### Menu items — `/api/v1/menu-item`

| Method | Path |
|--------|------|
| GET | `/api/v1/menu-item` |
| GET | `/api/v1/menu-item/{id}` |
| POST | `/api/v1/menu-item` |
| PUT | `/api/v1/menu-item/{id}` |
| DELETE | `/api/v1/menu-item/{id}` |

### Tables — `/api/v1/table`

| Method | Path |
|--------|------|
| GET | `/api/v1/table` |
| GET | `/api/v1/table/{id}` |
| POST | `/api/v1/table` |
| PUT | `/api/v1/table/{id}` |
| DELETE | `/api/v1/table/{id}` |

### Reviews — `/api/v1/review`

| Method | Path |
|--------|------|
| GET | `/api/v1/review` |
| GET | `/api/v1/review/{id}` |
| POST | `/api/v1/review` |
| PUT | `/api/v1/review/{id}` |
| DELETE | `/api/v1/review/{id}` |

### Contacts — `/api/v1/contact`

| Method | Path |
|--------|------|
| GET | `/api/v1/contact` |
| GET | `/api/v1/contact/{id}` |
| POST | `/api/v1/contact` |
| PUT | `/api/v1/contact/{id}` |
| DELETE | `/api/v1/contact/{id}` |

### Roles — `/api/v1/role`

| Method | Path |
|--------|------|
| GET | `/api/v1/role` |
| GET | `/api/v1/role/{id}` |
| POST | `/api/v1/role` |
| PUT | `/api/v1/role/{id}` |
| DELETE | `/api/v1/role/{id}` |

### Loyalty plans — `/api/v1/loyalty-plan`

| Method | Path |
|--------|------|
| GET | `/api/v1/loyalty-plan` |
| GET | `/api/v1/loyalty-plan/{id}` |
| POST | `/api/v1/loyalty-plan` |
| PUT | `/api/v1/loyalty-plan/{id}` |
| DELETE | `/api/v1/loyalty-plan/{id}` |

### Errors

| Status | Body |
|--------|------|
| 4xx/5xx | `{ "message": "..." }` |

---

## Quick Start for Reimplementation

```bash
# 1. Scaffold
ng new coffeeshop-frontend --standalone --routing --style=css

# 2. Copy conceptual layers:
#    - app.routes.ts (shops not tenants)
#    - services/ + models/ aligned to §8 and §16
#    - features/ per route
#    - shared/layout/

# 3. environment.apiUrl = http://localhost:8080

# 4. Run backend + OpenAPI at /swagger/index.html

# 5. Implement Keycloak token storage + refresh

# 6. Apply authGuard on layout children
```

This guide targets the **Spring Boot + Keycloak** coffee shop API: multi-shop management, menu/items, events, table-based reservations, and a reservation-request approval workflow.
