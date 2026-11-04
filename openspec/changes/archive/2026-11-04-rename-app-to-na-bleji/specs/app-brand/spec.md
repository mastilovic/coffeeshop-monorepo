# Spec Delta

## Purpose

Defines the product name users read in the web app, the phone app, browser chrome, and installed-app labels.

## ADDED Requirements

### Requirement: Visible product name

The web app and the phone app SHALL present the product name as the exact lowercase string `na bleji`. The string SHALL keep the space and SHALL NOT be title-cased.

#### Scenario: Web sidebar brand

- **WHEN** a signed-in user views the web app shell
- **THEN** the sidebar brand reads `na bleji`

#### Scenario: Web login copy

- **WHEN** a visitor opens the web login page
- **THEN** the subtitle reads `Sign in to your na bleji account`

#### Scenario: Web register copy

- **WHEN** a visitor opens the web register page
- **THEN** the subtitle reads `Join na bleji today`

#### Scenario: Browser tab

- **WHEN** a user opens the web app
- **THEN** the document title is `na bleji`

#### Scenario: Phone login heading

- **WHEN** a user opens the phone login screen
- **THEN** the heading reads `na bleji`

#### Scenario: App switcher title

- **WHEN** the phone app appears in the app switcher
- **THEN** its title is `na bleji`

### Requirement: Installed app labels

The Android launcher label, the iPhone home-screen name, the macOS app menu title, and the installable mobile-web name and page title SHALL each read `na bleji`.

#### Scenario: Android launcher

- **WHEN** the app is installed on Android
- **THEN** the launcher label is `na bleji`

#### Scenario: iPhone home screen

- **WHEN** the app is installed on iPhone
- **THEN** the name under the icon is `na bleji`

#### Scenario: macOS menu title

- **WHEN** the macOS app is running
- **THEN** the app menu title is `na bleji`

#### Scenario: Installed mobile web app

- **WHEN** the mobile web app is installed or opened in a browser
- **THEN** its installed name and page title are `na bleji`

### Requirement: Identity and hosts stay

The rename SHALL leave the Keycloak realm id, public hosts, and stored web session keys unchanged. A browser that already holds a session SHALL stay signed in. The hosted Keycloak page SHALL keep showing the realm id `coffeeshop`.

#### Scenario: Existing web session

- **WHEN** a browser already stores the current access and refresh token keys
- **THEN** those keys still restore the session after the visible rename

#### Scenario: Hosted Keycloak page

- **WHEN** a user opens the hosted Keycloak login page
- **THEN** the realm shown remains `coffeeshop`
