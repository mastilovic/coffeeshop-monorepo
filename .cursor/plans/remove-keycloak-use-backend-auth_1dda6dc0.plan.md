---
name: remove-keycloak-use-backend-auth
overview: Replace Keycloak-direct OIDC auth with backend API-based login/register in the Flutter mobile app. Remove openid_client and url_launcher dependencies, add email/password login form, and auto-login after registration.
todos:
  - id: remove-dependencies
    content: Remove openid_client and url_launcher from pubspec.yaml
    status: pending
  - id: clean-api-config
    content: Remove Keycloak-specific config (keycloakBaseUrl, keycloakRealm, keycloakClientId) from api_config.dart
    status: pending
  - id: simplify-auth-service
    content: Remove loginWithKeycloak(), rename loginWithCredentials→login(), update register() to auto-login
    status: pending
  - id: simplify-auth-notifier
    content: Remove loginWithKeycloak() from auth_notifier.dart, update register() flow
    status: pending
  - id: rebuild-login-screen
    content: Replace Keycloak button with email/password login form with validation, loading, and error states
    status: pending
  - id: update-register-screen
    content: Auto-login after successful registration instead of redirecting to /login
    status: pending
  - id: run-codegen
    content: Run build_runner to regenerate freezed/json files and verify no compile errors
    status: pending
isProject: false
---

# Plan: Replace Keycloak Direct Auth with Backend API Auth

## What Changes

The mobile app currently has two login paths: (1) Keycloak-direct OIDC via browser redirect, and (2) backend API credential login. This plan removes path (1) entirely and makes path (2) the sole login mechanism. Registration will also auto-login the user instead of redirecting to the login page.

## Files to Modify

### 1. `coffeeshop-mobile/pubspec.yaml` — Dependency cleanup
- Remove `openid_client: ^0.4.10`
- Remove `url_launcher: ^6.3.1`

### 2. `coffeeshop-mobile/lib/core/config/api_config.dart` — Remove Keycloak config
- Remove `keycloakBaseUrl` getter
- Remove `keycloakRealm` getter
- Remove `keycloakClientId` getter

### 3. `coffeeshop-mobile/lib/core/auth/auth_service.dart` — Simplify auth service
- Remove `import 'package:openid_client/openid_client_io.dart'` and `import 'package:url_launcher/url_launcher.dart'`
- Remove `loginWithKeycloak()` method entirely
- Rename `loginWithCredentials(String email, String password)` to `login(String email, String password)` and make it public
- Update `register()` to accept the same parameters and auto-login after successful registration (calls backend register → then immediately calls backend login → stores tokens → loads profile)

### 4. `coffeeshop-mobile/lib/core/auth/auth_notifier.dart` — Simplify notifier
- Remove `loginWithKeycloak()` method
- Update `register()` signature to auto-login flow (register + login + redirect handled by auth service)
- Keep `login()` method but update to use the renamed auth service method

### 5. `coffeeshop-mobile/lib/features/auth/login_screen.dart` — New login form
- Replace the single "Login with Keycloak" button with an email + password form:
  - Email field with validation
  - Password field with validation
  - "Login" submit button with loading state
  - Error display on failure
  - Link to register screen
- On success, the auth guard in `app_router.dart` will auto-redirect to `/dashboard`

### 6. `coffeeshop-mobile/lib/features/auth/register_screen.dart` — Auto-login after register
- After successful registration, instead of navigating to `/login`, automatically log the user in
- Show loading state during the auto-login phase
- On success, app auto-redirects to `/dashboard`
- On login failure after registration, redirect to `/login` with an appropriate message

## Files NOT Changed (no action needed)
- `token_storage.dart` — already works with tokens from backend API
- `auth_interceptor.dart` — already uses backend `/api/v2/auth/refresh` for token refresh
- `auth_api_service.dart` — already has `login()`, `register()`, `refresh()`, `getProfile()` methods hitting backend
- `dio_client.dart` — no changes; auth interceptor is added via `interceptor_init.dart`
- All models (`login_request.dart`, `register_request.dart`, `token_response.dart`) — already correct for backend API
- `app_router.dart` — auth guard already works with `AuthStatus.authenticated` state

## Related Skills
- `flutter-use-http-package` — guidance on Dio usage (already configured)
- `flutter-add-widget-test` — widget tests for the new login form (if requested)
- `fl-fix-runtime-errors` — if any runtime issues arise after changes
