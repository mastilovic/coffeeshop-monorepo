# Spec Delta

## ADDED Requirements

### Requirement: Coffee magnifier installed mark

Launcher icons, browser favicons, installable web-app icons, the Play listing icon, and the Play feature graphic SHALL show the coffee-cup magnifier on a charcoal field: a cream cup rim and handle forming a magnifying glass, brown coffee in the lens, and cream steam. Square icons SHALL NOT include wordmark text. Those surfaces SHALL NOT show the teal ring magnifier or the Flutter default placeholder.

#### Scenario: Android launcher icon

- **WHEN** the app is installed on Android
- **THEN** the launcher icon shows the coffee-cup magnifier on a charcoal field

#### Scenario: iPhone home-screen icon

- **WHEN** the app is installed on iPhone
- **THEN** the home-screen icon shows the coffee-cup magnifier on a charcoal field

#### Scenario: macOS app icon

- **WHEN** the macOS app icon is shown
- **THEN** it shows the coffee-cup magnifier on a charcoal field

#### Scenario: Windows app icon

- **WHEN** the Windows app icon is shown
- **THEN** it shows the coffee-cup magnifier on a charcoal field

#### Scenario: Angular web favicon

- **WHEN** a user opens the Angular web app
- **THEN** the browser favicon shows the coffee-cup magnifier on a charcoal field

#### Scenario: Mobile web favicon and PWA icons

- **WHEN** a user opens or installs the Flutter web app
- **THEN** the favicon, the PWA icons, and the maskable icons show the coffee-cup magnifier on a charcoal field

#### Scenario: Play listing icon

- **WHEN** the Play listing icon is viewed
- **THEN** it shows the coffee-cup magnifier on a charcoal field

#### Scenario: Play feature graphic

- **WHEN** the Play feature graphic is viewed
- **THEN** the left mark is the coffee-cup magnifier and the readable copy is still `Find`, `Cafes & Events`, and `Cafes and events, nearby.`

#### Scenario: Smallest square icons stay wordmark-free

- **WHEN** a launcher or favicon is shown at its smallest slot (16px macOS, 20px iOS, or the Flutter web favicon)
- **THEN** the artwork is the same coffee-cup mark scaled to that slot, with no product-name text drawn on the canvas

#### Scenario: Teal magnifier is not the installed mark

- **WHEN** an installed icon or the Play listing icon is shown
- **THEN** the artwork is not the teal ring-only magnifier

### Requirement: In-app brand glyphs stay

Replacing the installed mark SHALL leave the in-app glyphs unchanged. The web shell SHALL keep the coffee emoji beside the product name. The phone login screen SHALL keep the Material coffee icon.

#### Scenario: Web sidebar glyph

- **WHEN** a signed-in user views the web app shell
- **THEN** the sidebar still shows the coffee emoji beside `Find: Cafes & Events`

#### Scenario: Phone login glyph

- **WHEN** a user opens the phone login screen
- **THEN** the screen still shows the Material coffee icon above `Find: Cafes & Events`
