---
name: Optional favourite shops on create
overview: User creation already treats `favouriteShopIds` as optional in the mapper and service. The plan confirms that behavior and lists optional follow-ups (OpenAPI annotation, test) if you want the contract spelled out explicitly.
todos:
  - id: verify-client
    content: Confirm failure (if any) is not from client/OpenAPI client codegen requiring favouriteShopIds
    status: cancelled
  - id: optional-schema
    content: (Optional) Add @Schema NOT_REQUIRED + description on UserCreateRequest.favouriteShopIds
    status: completed
  - id: optional-test
    content: (Optional) Add POST user create test without favouriteShopIds
    status: completed
isProject: false
---

# Optional favourite shops on user create

## Current behavior (already optional)

The API already allows omitting favourite shops when creating a user:

1. **[`UserCreateRequest.java`](src/main/java/com/coffeeshop/coffeeshop/model/dto/request/UserCreateRequest.java)** — `favouriteShopIds` is a plain `List<UUID>` with no `@NotNull` / `@NotEmpty` (there are no Jakarta Validation annotations on any DTOs in this project).

2. **[`UserMapper.toUser(UserCreateRequest)`](src/main/java/com/coffeeshop/coffeeshop/mapper/UserMapper.java)** — Shops are set only when the list is present and non-empty:

```75:77:src/main/java/com/coffeeshop/coffeeshop/mapper/UserMapper.java
        if (request.getFavouriteShopIds() != null && !request.getFavouriteShopIds().isEmpty()) {
            user.setShops(stubShops(request.getFavouriteShopIds()));
        }
```

If the property is omitted or `null`, `User.shops` stays `null`. An empty JSON array `[]` also skips this block (same outcome: no favourites on create).

3. **[`UserServiceImpl.create`](src/main/java/com/coffeeshop/coffeeshop/service/impl/UserServiceImpl.java)** — Resolves and persists favourite links only when `entity.getShops()` is non-null and non-empty:

```63:65:src/main/java/com/coffeeshop/coffeeshop/service/impl/UserServiceImpl.java
        if (entity.getShops() != null && !entity.getShops().isEmpty()) {
            entity.setShops(resolveShops(entity.getShops()));
        }
```

4. **Responses** — [`MappingUtils.mapList`](src/main/java/com/coffeeshop/coffeeshop/mapper/MappingUtils.java) turns a null `User.shops` into an empty list for `UserResponseDto.favouriteShops`, so the client does not see a null list.

**Conclusion:** No functional change is strictly required for “optional favourite shops on create” unless you are hitting a different layer (e.g. client validation, a proxy spec, or another endpoint).

## Optional improvements (if you want explicit contract or regression safety)

- **OpenAPI / Swagger** — The project uses [`springdoc-openapi-starter-webmvc-ui`](build.gradle). To make “optional” obvious in Swagger UI, add `@Schema(requiredMode = Schema.RequiredMode.NOT_REQUIRED)` (and a short `description`) on `favouriteShopIds` in `UserCreateRequest`. This is documentation-only; it does not change runtime behavior.

- **Regression test** — Add a test that `POST /api/v1/user/` with a body that omits `favouriteShopIds` returns `201` and `favouriteShops` empty or absent as serialized. (No test file for users exists yet under `src/test`.)

## Implementation note (java-agent)

After you approve this plan, the **java-agent** can apply the optional `@Schema` change and/or add the test in one pass; if you only need behavior, **no code changes** are necessary beyond verifying your client does not require the field.
