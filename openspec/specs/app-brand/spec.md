# app-brand Specification

## Purpose

Defines the product name users read in the web app, the phone app, browser chrome, and installed-app labels.

## Requirements

### Requirement: Visible product name

The web app and the phone app SHALL present the full product name as the exact string `Find: Cafes & Events` (capitalization, colon, spaces, and ampersand preserved). Auth subtitles SHALL use the short product name `Find`.

#### Scenario: Web sidebar brand

- **WHEN** a signed-in user views the web app shell
- **THEN** the sidebar brand reads `Find: Cafes & Events`

#### Scenario: Web login copy

- **WHEN** a visitor opens the web login page
- **THEN** the subtitle reads `Sign in to your Find account`

#### Scenario: Web register copy

- **WHEN** a visitor opens the web register page
- **THEN** the subtitle reads `Join Find today`

#### Scenario: Browser tab

- **WHEN** a user opens the web app
- **THEN** the document title is `Find: Cafes & Events`

#### Scenario: Phone login heading

- **WHEN** a user opens the phone login screen
- **THEN** the heading reads `Find: Cafes & Events`

#### Scenario: App switcher title

- **WHEN** the phone app appears in the app switcher
- **THEN** its title is `Find: Cafes & Events`

### Requirement: Installed app labels

The Android launcher label, the iPhone home-screen name, the macOS app menu title, and the installable mobile-web short name and apple-mobile-web-app title SHALL each read the short product name `Find`. The installable mobile-web full name and page title SHALL read `Find: Cafes & Events`.

#### Scenario: Android launcher

- **WHEN** the app is installed on Android
- **THEN** the launcher label is `Find`

#### Scenario: iPhone home screen

- **WHEN** the app is installed on iPhone
- **THEN** the name under the icon is `Find`

#### Scenario: macOS menu title

- **WHEN** the macOS app is running
- **THEN** the app menu title is `Find`

#### Scenario: Installed mobile web app

- **WHEN** the mobile web app is installed or opened in a browser
- **THEN** its installed full name and page title are `Find: Cafes & Events` and its short name and apple-mobile-web-app title are `Find`

### Requirement: Identity and hosts stay

The rename SHALL leave the Keycloak realm id, public hosts, and stored web session keys unchanged. A browser that already holds a session SHALL stay signed in. The hosted Keycloak page SHALL keep showing the realm id `coffeeshop`.

#### Scenario: Existing web session

- **WHEN** a browser already stores the current access and refresh token keys
- **THEN** those keys still restore the session after the visible rename

#### Scenario: Hosted Keycloak page

- **WHEN** a user opens the hosted Keycloak login page
- **THEN** the realm shown remains `coffeeshop`
