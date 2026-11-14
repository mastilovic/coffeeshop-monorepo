# Spec Delta

## ADDED Requirements

### Requirement: Find magnifier launcher icon

**Superseded:** Do not sync this requirement. `coffee-magnifier-logo` replaces the teal magnifier with the coffee-cup magnifier. Sync that change's "Coffee magnifier installed mark" requirement instead.

Installed Android and iPhone launcher icons, Flutter web favicon and PWA icons, and the Angular web favicon SHALL present the static Find magnifier mark on a deep teal / charcoal field. The icons SHALL NOT retain the Flutter default coffee or placeholder artwork. The mark SHALL be a magnifying glass without wordmark text on the icon canvas.

#### Scenario: Android launcher icon

- **WHEN** the app is installed on Android
- **THEN** the launcher icon shows the Find magnifier mark on a deep teal / charcoal field

#### Scenario: iPhone home-screen icon

- **WHEN** the app is installed on iPhone
- **THEN** the home-screen icon shows the Find magnifier mark on a deep teal / charcoal field

#### Scenario: Mobile web favicon and PWA icons

- **WHEN** a user opens or installs the Flutter web app
- **THEN** the favicon and PWA icons show the Find magnifier mark on a deep teal / charcoal field

#### Scenario: Angular web favicon

- **WHEN** a user opens the Angular web app
- **THEN** the browser favicon shows the Find magnifier mark on a deep teal / charcoal field
