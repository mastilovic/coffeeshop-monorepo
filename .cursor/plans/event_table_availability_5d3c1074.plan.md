---
name: Event table availability
overview: Enforce max reservations per event equal to shop table count and expose per-event availability (remaining tables) to the Angular UI wherever events appear, so users can reserve only when slots remain.
todos:
  - id: backend-counts-enforce
    content: Add `countByEvent_EventId`/`countByShop_Id`; implement availability helper and enforce on reservation create + reservation-request create + accept.
    status: completed
  - id: backend-dto-wire
    content: Extend `EventResponseDto` + mapping so list/detail/search/shop embed paths return total/reserved/free + `isFull`.
    status: completed
  - id: backend-tests
    content: Add/update integration tests for capacity conflict + DTO availability correctness.
    status: completed
  - id: frontend-ui
    content: Extend `event.model.ts` and update events/reservations/shop-details components to render availability and gate reserve UX; handle backend 409 on submit.
    status: completed
isProject: false
---

# Event table capacity + availability

## Decisions captured (skipped questions defaulted)

- **Capacity definition**: **`reservedTables` = count of persisted `Reservation` rows for `event_id`**. Pending `ReservationRequest` rows **do not** consume capacity (they are queue/waitlist until accepted), but capacity is enforced before creating a pending request anyway so queues cannot silently exceed physical tables given your UX (“see tables left”).
- **Enforcement timing**: enforce on **every slot-consuming write** (`POST /reservation`, `POST /reservation-request`, and **`POST`/accept on reservation-request** stays redundant-safe with a transactional re-check).

## Backend (Spring) changes

### 1) Persisted counts + transactional checks

- Add repository helpers:
  - [`coffeeshop/src/main/java/com/coffeeshop/coffeeshop/repository/ReservationRepository.java`](coffeeshop/src/main/java/com/coffeeshop/coffeeshop/repository/ReservationRepository.java): `long countByEvent_EventId(String eventId);`
  - [`coffeeshop/src/main/java/com/coffeeshop/coffeeshop/repository/TableRepository.java`](coffeeshop/src/main/java/com/coffeeshop/coffeeshop/repository/TableRepository.java): `long countByShop_Id(UUID shopId);` (consistent with Java agent findings)
- Implement a small internal helper/service (recommended to avoid duplication):
  - e.g. `EventTableAvailabilityService` with `assertHasFreeTable(Event event)` and `AvailabilitySnapshot summarize(Event event)`
  - Computations:
    - `totalTables = tableRepository.countByShop_Id(event.getShop().getId())`
    - `reservedTables = reservationRepository.countByEvent_EventId(event.getEventId())`
    - `freeTables = max(totalTables - reservedTables, 0)`
    - reject with **`409 CONFLICT`** when attempting to allocate another reservation slot and `reservedTables >= totalTables` (or when `totalTables == 0`).

### 2) Wire enforcement into mutation paths

- [`coffeeshop/src/main/java/com/coffeeshop/coffeeshop/service/impl/ReservationServiceImpl.java`](coffeeshop/src/main/java/com/coffeeshop/coffeeshop/service/impl/ReservationServiceImpl.java)
  - In `create(...)`, after event/shop validation and before `save`: call availability assert (counts current DB state before insert).
- [`coffeeshop/src/main/java/com/coffeeshop/coffeeshop/service/impl/ReservationRequestServiceImpl.java`](coffeeshop/src/main/java/com/coffeeshop/coffeeshop/service/impl/ReservationRequestServiceImpl.java)
  - In `createRequest(...)`: availability assert against the requested event **before persisting pending request** (aligns UX with “reserve” meaning there is remaining capacity).
  - In accept flow (where reservation is actually created): keep a **second assert** immediately before creating reservation to guard races.

### 3) API contract: expose availability on Event DTO responses

- Extend [`coffeeshop/src/main/java/com/coffeeshop/coffeeshop/model/dto/response/EventResponseDto.java`](coffeeshop/src/main/java/com/coffeeshop/coffeeshop/model/dto/response/EventResponseDto.java) with numeric fields matching UI needs:
  - `totalTables`, `reservedTables`, `freeTables`, and optional `full`/`isFull` (boolean derived as `freeTables <= 0`)
- Populate consistently anywhere `EventResponseDto` is emitted:
  - [`coffeeshop/src/main/java/com/coffeeshop/coffeeshop/controller/EventController.java`](coffeeshop/src/main/java/com/coffeeshop/coffeeshop/controller/EventController.java)
  - [`coffeeshop/src/main/java/com/coffeeshop/coffeeshop/mapper/EventMapper.java`](coffeeshop/src/main/java/com/coffeeshop/coffeeshop/mapper/EventMapper.java) plus any service/controller paths that assemble `ShopResponseDto.events` lists (follow call sites from `Shop` retrieval).

**Optional (not required for UI listed below)**: add `GET /api/v1/event/{eventId}/availability` if you want a dedicated troubleshooting endpoint; frontend can rely on embedded fields alone.

### 4) Tests

Extend/add integration tests around existing suites:

- [`coffeeshop/src/test/java/com/coffeeshop/coffeeshop/ReservationEventCreateIntegrationTest.java`](coffeeshop/src/test/java/com/coffeeshop/coffeeshop/ReservationEventCreateIntegrationTest.java): verify `409` when event reaches capacity for owner direct reservations.
- [`coffeeshop/src/test/java/com/coffeeshop/coffeeshop/ReservationRequestIntegrationTest.java`](coffeeshop/src/test/java/com/coffeeshop/coffeeshop/ReservationRequestIntegrationTest.java): verify pending request blocked when full; verify accept respects race-safe re-check.
- Add/update an event-fetch test ([`EventSearchIntegrationTest.java`](coffeeshop/src/test/java/com/coffeeshop/coffeeshop/EventSearchIntegrationTest.java) or new focused test): assert availability fields correctness after creating reservations.

## Frontend (Angular) changes

### 1) Models

- Extend [`coffeeshop-frontend/src/app/models/event.model.ts`](coffeeshop-frontend/src/app/models/event.model.ts) with `totalTables`, `reservedTables`, `freeTables`, `isFull` (match backend naming).

### 2) Visibility + disabling reserve actions

- [`coffeeshop-frontend/src/app/features/events/events.component.ts`](coffeeshop-frontend/src/app/features/events/events.component.ts)
  - Show availability column (`X left` / `Full`).
  - Extend `canReserveForEvent(...)` so it requires **`freeTables > 0`** (in addition to current date gate).
  - Extend tooltip messaging for full events.
- [`coffeeshop-frontend/src/app/features/reservations/reservations.component.ts`](coffeeshop-frontend/src/app/features/reservations/reservations.component.ts)
  - Include availability text in selectable event labels (request + direct paths).
  - Filter selectable events to exclude full events (`freeTables <= 0`).
  - Defensive guards in submit handlers to handle stale UI if another user consumes last slot (**expect `409`**, show toast).
- [`coffeeshop-frontend/src/app/features/shop-details/shop-details.component.ts`](coffeeshop-frontend/src/app/features/shop-details/shop-details.component.ts)
  - Add availability display in embedded events lists.

## Behavioral notes / edge cases

- **Concurrency**: counts + insert should be evaluated in **same transaction**; accept-path re-check closes most races.
- **Deleting/canceling reservations**: no special-case needed if counts are purely DB-derived.
- **Shop with 0 tables**: treat as `freeTables = 0` and block allocates with a clear conflict message.

