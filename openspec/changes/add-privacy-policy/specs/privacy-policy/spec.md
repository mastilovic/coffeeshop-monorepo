# Spec Delta

## Purpose

Provides a public privacy policy for Find that store listings and both clients can point to, with in-app entry points on web and mobile.

## ADDED Requirements

### Requirement: Public privacy policy page

The web app SHALL expose a privacy policy at the path `/privacy-policy` that is reachable without authentication. The page SHALL present draft policy text that covers account and identity data (including authentication via Keycloak), reservation-related personal data, and billing/subscription-related personal data. The page SHALL use the short product name `Find` where the product is named.

#### Scenario: Unauthenticated visitor opens the policy

- **WHEN** a visitor who is not signed in navigates to `/privacy-policy`
- **THEN** the privacy policy page is shown without redirecting to login

#### Scenario: Policy covers required topics

- **WHEN** a visitor views `/privacy-policy`
- **THEN** the page content mentions accounts/identity (Keycloak), reservations, and billing or subscriptions

#### Scenario: Signed-in user opens the policy

- **WHEN** a signed-in user navigates to `/privacy-policy`
- **THEN** the privacy policy page is shown (the route remains public and is not behind the authenticated shell)

### Requirement: Web entry points to the privacy policy

The web app SHALL provide a navigation link to `/privacy-policy` on the login page, the register page, and the signed-in profile page.

#### Scenario: Login page link

- **WHEN** a visitor views the login page
- **THEN** a link labeled for the privacy policy navigates to `/privacy-policy`

#### Scenario: Register page link

- **WHEN** a visitor views the register page
- **THEN** a link labeled for the privacy policy navigates to `/privacy-policy`

#### Scenario: Profile page link

- **WHEN** a signed-in user views the profile page
- **THEN** a link labeled for the privacy policy navigates to `/privacy-policy`

### Requirement: Mobile opens the hosted privacy policy

The phone app SHALL provide a Profile action that opens the canonical public privacy policy URL in the device’s system browser. The canonical URL SHALL be `https://app.kafenerija.online/privacy-policy` unless a build-time configuration overrides the host. The phone app SHALL NOT embed a separate offline copy of the policy text.

#### Scenario: Profile opens the policy URL

- **WHEN** a signed-in user chooses the privacy policy action on the Profile screen
- **THEN** the system browser opens `https://app.kafenerija.online/privacy-policy` (or the configured host equivalent ending in `/privacy-policy`)

#### Scenario: No native duplicate policy screen

- **WHEN** a user opens the privacy policy from Profile
- **THEN** the app does not present an in-app screen that duplicates the policy body as local static text
