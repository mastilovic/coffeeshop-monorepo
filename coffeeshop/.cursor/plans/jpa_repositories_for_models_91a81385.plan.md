---
name: JPA repositories for models
overview: Add one Spring Data `JpaRepository` interface per JPA entity in `com.coffeeshop.coffeeshop.model`, matching the minimal style of [ShopRepository.java](src/main/java/com/coffeeshop/coffeeshop/repository/ShopRepository.java). Skip enum types. Use `JpaRepository<Event, String>` because `Event`’s `@Id` is `eventId` (String).
todos:
  - id: add-repo-interfaces
    content: Create 10 repository interfaces under repository/ (User, Menu, MenuItem, Reservation, Review, LoyaltyPlan, Role, Table, Contact, Event) mirroring ShopRepository; Event uses String ID.
    status: completed
  - id: verify-compile
    content: Run Maven compile to verify generics and imports (especially Table vs java.sql.Table).
    status: completed
isProject: false
---

# JPA repositories for domain models

## Reference pattern

[`ShopRepository.java`](src/main/java/com/coffeeshop/coffeeshop/repository/ShopRepository.java) is the template:

- Package: `com.coffeeshop.coffeeshop.repository`
- `extends JpaRepository<Entity, IdType>`
- `@Repository` on the interface
- `java.util.UUID` import for UUID primary keys
- No custom methods unless you later need queries (same as `ShopRepository`)

## Entities and repository mapping

| Entity | ID type | New interface |
|--------|---------|---------------|
| `User` | `UUID` | `UserRepository` |
| `Menu` | `UUID` | `MenuRepository` |
| `MenuItem` | `UUID` | `MenuItemRepository` |
| `Reservation` | `UUID` | `ReservationRepository` |
| `Review` | `UUID` | `ReviewRepository` |
| `LoyaltyPlan` | `UUID` | `LoyaltyPlanRepository` |
| `Role` | `UUID` | `RoleRepository` |
| `Table` | `UUID` | `TableRepository` |
| `Contact` | `UUID` | `ContactRepository` |
| `Event` | `String` | `EventRepository` extends `JpaRepository<Event, String>` |

**Already present:** `ShopRepository` for `Shop` / `UUID`.

**Out of scope:** [`RoleType`](src/main/java/com/coffeeshop/coffeeshop/model/enums/RoleType.java), [`LoyaltyPlanType`](src/main/java/com/coffeeshop/coffeeshop/model/enums/LoyaltyPlanType.java), [`UserType`](src/main/java/com/coffeeshop/coffeeshop/model/enums/UserType.java) — plain enums, not `@Entity`.

## Implementation notes

1. **`Event` ID** — The primary key field is `eventId` (`String`), not `UUID`. Spring Data uses the entity’s `@Id` type; the second generic parameter must be `String`.

2. **`Table` entity** — Class name is `Table` ([`restaurant_table`](src/main/java/com/coffeeshop/coffeeshop/model/Table.java) in the DB). In `TableRepository`, import `com.coffeeshop.coffeeshop.model.Table` explicitly so it is not confused with `java.sql.Table`.

3. **Component scan** — [`CoffeeshopApplication`](src/main/java/com/coffeeshop/coffeeshop/CoffeeshopApplication.java) uses `@SpringBootApplication` on `com.coffeeshop.coffeeshop`, so [`repository`](src/main/java/com/coffeeshop/coffeeshop/repository/) is scanned automatically; no extra configuration.

4. **Style (java-agent)** — When implementing (including via java-agent), follow [.cursor/agents/java-agent.md](.cursor/agents/java-agent.md): `@Repository` on repository types, 4-space indent, no comments in these interfaces, no drive-by refactors elsewhere.

## Verification

- Run `./mvnw -q compile` (or your usual build) to confirm interfaces resolve and generics match each entity’s `@Id` type.

## Optional follow-ups (not required for this task)

- Add derived query methods (e.g. `Optional<User> findByEmail(String email)`) when services/controllers need them.
- Add `@EntityGraph` or fetch tuning if lazy-loading issues appear later; current entities use a mix of `EAGER` associations on the model side.
