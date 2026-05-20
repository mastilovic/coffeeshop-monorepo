---
name: REST controllers CRUD plan
overview: Extend [`ShopController`](file:///Users/amastilovic/Desktop/dev/coffeeshop/src/main/java/com/coffeeshop/coffeeshop/controller/ShopController.java) to full CRUD and add matching `@RestController` classes for the other ten services, mirroring your existing style (`ResponseEntity`, constructor injection, `/api/v1/...` paths). Add a global exception handler mapping `ResourceNotFoundException` and `IllegalArgumentException` to HTTP status codes, and address Spring Security so `/api/**` is reachable during development.
todos:
  - id: security-exception
    content: Add SecurityFilterChain (permit /api/**) and GlobalExceptionHandler for ResourceNotFoundException (404) + IllegalArgumentException (400)
    status: completed
  - id: shop-controller-crud
    content: Extend ShopController with GET by id, POST, PUT, DELETE; align constructor with java-agent (final)
    status: completed
  - id: remaining-controllers
    content: Add 10 controllers (User..Reservation) with same CRUD mapping; Event uses String path variable
    status: completed
  - id: user-json-ignore
    content: Add @JsonIgnore on User password for API safety (or document DTO follow-up)
    status: completed
  - id: verify-api
    content: Run ./gradlew test; smoke-check API if dev server starts
    status: completed
isProject: false
---

# REST layer CRUD implementation plan

## Reference pattern

Match [`ShopController`](file:///Users/amastilovic/Desktop/dev/coffeeshop/src/main/java/com/coffeeshop/coffeeshop/controller/ShopController.java):

- `@RestController`, `@CrossOrigin(origins = "*")`, `@RequestMapping("/api/v1/<resource>")`
- Constructor injection (add `final` field and `final` constructor parameter per [java-agent](file:///Users/amastilovic/Desktop/dev/coffeeshop/.cursor/agents/java-agent.md))
- `ResponseEntity` with explicit `HttpStatus` (e.g. `OK` for reads/list, `CREATED` for POST with body, `NO_CONTENT` for DELETE if you return void)
- Request bodies: JPA entities as JSON (same as current `List<Shop>` response) — **no DTO layer** unless you expand scope later

## URL map (one controller per aggregate)

Use lowercase, hyphenate multi-word paths for readability:

| Controller | Base path | ID type |
|------------|-----------|---------|
| Shop (extend) | `/api/v1/shop` | `UUID` |
| User | `/api/v1/user` | `UUID` |
| Role | `/api/v1/role` | `UUID` |
| Menu | `/api/v1/menu` | `UUID` |
| MenuItem | `/api/v1/menu-item` | `UUID` |
| LoyaltyPlan | `/api/v1/loyalty-plan` | `UUID` |
| Event | `/api/v1/event` | `String` (`eventId`) |
| Table | `/api/v1/table` | `UUID` |
| Review | `/api/v1/review` | `UUID` |
| Contact | `/api/v1/contact` | `UUID` |
| Reservation | `/api/v1/reservation` | `UUID` |

## Endpoints (each controller except list-only legacy)

For every resource, align with existing service methods in [`service/*Service.java`](file:///Users/amastilovic/Desktop/dev/coffeeshop/src/main/java/com/coffeeshop/coffeeshop/service):

- `GET ""` or `GET "/"` — `findAll()` → `200 OK` with list (same as current shop list)
- `GET "/{id}"` — `getById` → `200 OK` with body
- `POST ""` or `POST "/"` — `create(@RequestBody entity)` → `201 CREATED` with saved entity (and optionally `Location` header — optional enhancement)
- `PUT "/{id}"` — `update(id, @RequestBody entity)` → `200 OK` with updated entity
- `DELETE "/{id}"` — `deleteById(id)` → `204 NO_CONTENT` (no body)

**Event**: path variable name `eventId` (String), matching [`EventService`](file:///Users/amastilovic/Desktop/dev/coffeeshop/src/main/java/com/coffeeshop/coffeeshop/service/EventService.java).

**Shop**: Extend [`ShopController`](file:///Users/amastilovic/Desktop/dev/coffeeshop/src/main/java/com/coffeeshop/coffeeshop/controller/ShopController.java) with `getById`, `create`, `update`, `delete` using [`ShopService`](file:///Users/amastilovic/Desktop/dev/coffeeshop/src/main/java/com/coffeeshop/coffeeshop/service/ShopService.java).

## Global exception handling (java-agent alignment)

Add `@RestControllerAdvice` (e.g. in [`exception/GlobalExceptionHandler.java`](file:///Users/amastilovic/Desktop/dev/coffeeshop/src/main/java/com/coffeeshop/coffeeshop/exception/GlobalExceptionHandler.java) or `controller/advice`):

- [`ResourceNotFoundException`](file:///Users/amastilovic/Desktop/dev/coffeeshop/src/main/java/com/coffeeshop/coffeeshop/exception/ResourceNotFoundException.java) → **404** with a small JSON error body (message field) or plain text — pick one structure and reuse
- `IllegalArgumentException` (validation from services) → **400**

This replaces silent 500s for the common service failures.

## Spring Security ([`build.gradle`](file:///Users/amastilovic/Desktop/dev/coffeeshop/build.gradle) includes `spring-boot-starter-security`)

There is **no** `SecurityFilterChain` in the repo today; Boot’s defaults often make unauthenticated calls to `/api/**` fail. Add a minimal `SecurityConfiguration` that permits all requests to `/api/**` (and optionally actuator) for local/dev parity with your open `@CrossOrigin`. Defer `@PreAuthorize` until you have real authentication (per java-agent: use it when Spring Security enforces roles).

## Entity exposure caveat (User)

[`User`](file:///Users/amastilovic/Desktop/dev/coffeeshop/src/main/java/com/coffeeshop/coffeeshop/model/User.java) includes `password`. Returning it from `UserController` mirrors “entities everywhere” but leaks secrets. Minimal mitigation without DTOs: add `@JsonIgnore` on `password` getters/setters or field (small model change), or document that DTOs are required next — **recommend `@JsonIgnore` on password for JSON serialization** as part of this work.

## Verification

- `./gradlew test` (and optionally manual `curl` against a running app) once Security permits `/api/**`
- Optional: `@WebMvcTest` per controller with `@MockBean` service — not required by the service plan but fits java-agent

## Files to add or touch

**New:** `UserController`, `RoleController`, `MenuController`, `MenuItemController`, `LoyaltyPlanController`, `EventController`, `TableController`, `ReviewController`, `ContactController`, `ReservationController`; `GlobalExceptionHandler`; `SecurityConfiguration` (or equivalent bean name under `config/`).

**Edit:** [`ShopController.java`](file:///Users/amastilovic/Desktop/dev/coffeeshop/src/main/java/com/coffeeshop/coffeeshop/controller/ShopController.java); optionally [`User.java`](file:///Users/amastilovic/Desktop/dev/coffeeshop/src/main/java/com/coffeeshop/coffeeshop/model/User.java) for `@JsonIgnore` on password.
