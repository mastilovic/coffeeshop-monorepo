---
title: Auth and identity
created: 2026-11-04
updated: 2026-11-04
tags:
  - knowledge
  - auth
  - keycloak
---

# Auth and Identity

## Summary

Users sign in through the Go API. Keycloak stays behind that API. The string people read (`na bleji`) and the string the identity system uses (`coffeeshop`) are deliberately different.

## Durable Decisions

- Web and mobile call `POST /api/v2/auth/login`, `/refresh`, and `/logout`. They store the access and refresh tokens and send `Authorization: Bearer`. Cookie-only auth is legacy.
- The phone app used to talk to Keycloak through its SDK. That path was removed. Do not add a Keycloak client SDK back on either client.
- The Keycloak realm id stays `coffeeshop`. Public hosts and stored web session keys stay as they are. A rename of the visible product name must not change them, or existing sessions and the hosted login page break.
- Android package id remains `com.coffeeshop.mobile` even though the launcher label is `na bleji`.
- Local Keycloak is `start-dev` with `--import-realm` from `coffeeshop/docker/keycloak/realm-coffeeshop.json`. Do not set `KC_HOSTNAME` in local Compose. If it is set to the Docker service name `keycloak`, the admin console loads forever because the browser cannot resolve that host. The API container should still call `http://keycloak:8080`.

## Why

The admin-console failure looks like a healthy container and a hung page. The realm and package ids are stable identifiers; the display name is not one of them.

## References and Caveat

- [Keycloak notes](../../coffeeshop/docs/keycloak.md) — the hostname symptom and token lifetimes. Some endpoint examples there still say `/api/v1`; the live clients use `/api/v2`.
- [App brand spec](../../openspec/specs/app-brand/spec.md)
- Token lifetimes in the imported realm are 1 hour for access tokens, 30 days idle, and 60 days hard cap. Changing them requires recreating Keycloak, and users must sign in again.

Verify issuer, client id, and session storage keys in the current env and clients before changing auth.
