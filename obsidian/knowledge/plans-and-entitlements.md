---
title: Plans and entitlements
created: 2026-11-04
updated: 2026-11-04
tags:
  - knowledge
  - subscription
  - loyalty
---

# Plans and Entitlements

## Summary

The API has two unrelated "plan" concepts. Owner subscriptions gate what a shop owner can do and how they are billed. Loyalty plans are a shop's offer to its customers.

## Which One You Mean

| | Owner subscription | Loyalty plan |
|---|---|---|
| Who it is for | The shop owner | Customers of one shop |
| Tiers | Starter, Growth, Pro, plus a custom builder | `BASIC`, `PREMIUM`, `VIP` |
| API | `/api/v2/subscription`, `/api/v2/admin/subscription` | `/api/v2/loyalty-plan` |
| Code | `coffeeshop-go/internal/subscription` | `coffeeshop-go/internal/handler/loyalty_plan.go` |
| UI | Billing and admin subscription screens on web and mobile | Loyalty management on a shop |

## Durable Details

- Billing is a base owner plan plus an add-on for each shop past the plan's included shop. Starter is the free tier and is capped at one shop. Amounts and limits live in the subscription package and the admin pricing screen; do not hardcode a second copy in a client.
- Role checks are not a substitute for entitlement checks. `SHOP_OWNER` and an `OWNER` or `EMPLOYEE` shop relationship decide who may act for a shop. The subscription gate decides whether that action is included in the plan.
- Web permission checks are still scattered (`userType`, shop ownership, admin). Mobile consolidates role checks in `coffeeshop-mobile/lib/core/auth/user_permissions.dart`. A gate added on only one client will drift.

## Reference

- [Owner subscription product spec](../../coffeeshop/docs/subscription-plan.md)

The July 2026 spec describes the intended product. Prefer the Go entitlement tests and the billing screens when they disagree with that spec.
