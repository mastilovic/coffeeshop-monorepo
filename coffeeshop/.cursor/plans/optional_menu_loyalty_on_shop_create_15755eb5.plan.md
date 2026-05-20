---
name: Optional menu loyalty on shop create
overview: Shop creation already omits menu and loyalty plan when `menuId` / `loyaltyPlanId` are absent; no behavioral fix is required unless you want explicit OpenAPI docs, stricter JPA column metadata, or a regression test. After approval, the java-agent can apply the optional documentation/test changes.
todos:
  - id: verify-runtime
    content: If a failure persists, capture request JSON + stack trace; confirm DB `shop.menu_id` / `loyalty_plan_id` allow NULL in non-dev DBs
    status: pending
  - id: schema-shop-create
    content: (Optional) Add @Schema NOT_REQUIRED + descriptions on ShopCreateRequest.menuId and loyaltyPlanId
    status: pending
  - id: test-shop-create
    content: "(Optional) Add ShopCreateIntegrationTest: POST /api/v1/shop without menuId/loyaltyPlanId returns 201"
    status: pending
  - id: joincolumn-optional
    content: (Optional) Add nullable=true on Shop menu/loyaltyPlan @JoinColumn for explicit JPA intent
    status: pending
isProject: false
---

# Optional `menu` and `loyaltyPlan` on shop create

## Request shape (important)

The create body is [`ShopCreateRequest`](src/main/java/com/coffeeshop/coffeeshop/model/dto/request/ShopCreateRequest.java): optional link fields are **`menuId`** and **`loyaltyPlanId`** (UUIDs), not nested `menu` / `loyaltyPlan` objects. Omitting those properties (or sending `null`) is the supported way to create a shop without a menu or loyalty plan.

## Current behavior (already optional)

1. **DTO** — `menuId` and `loyaltyPlanId` are plain `UUID` fields with **no** Jakarta Validation (`@NotNull`, etc.), consistent with other request DTOs in this project.

2. **Mapping** — [`ShopMapper.toShop(ShopCreateRequest)`](src/main/java/com/coffeeshop/coffeeshop/mapper/ShopMapper.java) only sets `Shop.menu` / `Shop.loyaltyPlan` when the corresponding ID is non-null:

```87:96:src/main/java/com/coffeeshop/coffeeshop/mapper/ShopMapper.java
        if (request.getMenuId() != null) {
            final Menu menu = new Menu();
            menu.setId(request.getMenuId());
            shop.setMenu(menu);
        }
        if (request.getLoyaltyPlanId() != null) {
            final LoyaltyPlan plan = new LoyaltyPlan();
            plan.setId(request.getLoyaltyPlanId());
            shop.setLoyaltyPlan(plan);
        }
```

3. **Service** — [`ShopServiceImpl.create`](src/main/java/com/coffeeshop/coffeeshop/service/impl/ShopServiceImpl.java) only loads and attaches menu/loyalty entities when they are non-null on the incoming `Shop`.

4. **Response** — [`MenuMapper.toMenuResponse`](src/main/java/com/coffeeshop/coffeeshop/mapper/MenuMapper.java) and [`LoyaltyPlanMapper.toLoyaltyPlanResponse`](src/main/java/com/coffeeshop/coffeeshop/mapper/LoyaltyPlanMapper.java) return `null` when the entity is missing, so `ShopResponseDto.menu` / `loyaltyPlan` serialize as JSON `null` (not a failure).

5. **JPA** — [`Shop`](src/main/java/com/coffeeshop/coffeeshop/model/Shop.java) owns the `@JoinColumn` for `menu_id` and `loyalty_plan_id`. Default JPA `nullable` for join columns is `true`, so Hibernate-generated DDL should allow NULL FKs unless an existing database was created with different constraints (worth a quick check only if you see insert errors in a long-lived DB).

**Conclusion:** If something still fails when omitting menu/loyalty, the cause is likely outside this path (client expecting different JSON keys, a generated client marking fields required, or legacy DB NOT NULL). The Java create pipeline does not require those IDs today.

## Optional follow-ups (recommended for clarity, not for core behavior)

- **OpenAPI / Swagger** — Add `@Schema(requiredMode = Schema.RequiredMode.NOT_REQUIRED, description = "...")` on `menuId` and `loyaltyPlanId` in `ShopCreateRequest` (and optionally the same on [`ShopUpdateRequest`](src/main/java/com/coffeeshop/coffeeshop/model/dto/request/ShopUpdateRequest.java) for consistency). This matches the approach in your [optional favourite shops plan](.cursor/plans/optional_favourite_shops_on_create_2d56bb74.plan.md): documentation-only, no runtime change.

- **Regression test** — Add `ShopCreateIntegrationTest` (same style as [`UserCreateIntegrationTest`](src/test/java/com/coffeeshop/coffeeshop/UserCreateIntegrationTest.java)): `POST` [`/api/v1/shop`](src/main/java/com/coffeeshop/coffeeshop/controller/ShopController.java) with a minimal body (name, address, phone, email only), assert `201` and `menu` / `loyaltyPlan` null or absent in the JSON map as appropriate.

- **Explicit JPA** — Optionally set `@JoinColumn(..., nullable = true)` on `menu` and `loyaltyPlan` in `Shop` to make the intended schema obvious in code (redundant with defaults but harmless).

## Out of scope unless you ask

- **Nested create payloads** (e.g. embedding full `menu` / `loyaltyPlan` objects in the shop create body) would require new DTO fields and mapping logic; not present today.
- **Clearing menu/loyalty on update** — Current partial-update logic only applies new values when non-null; clearing associations is a separate design (e.g. explicit null or a patch DTO).

## Implementation after you approve

Have the **java-agent** apply only what you want from the optional follow-ups (typically `@Schema` + one integration test); no service/mapper change is needed for “optional on create” if the issue is purely API contract or confidence.
