# Spec Delta

## Purpose

Defines where shop-owner dashboard notifications go and how the shops list shows which shops received reviews in the last 30 days.

## ADDED Requirements

### Requirement: Pending reservation notification opens shop management

The system SHALL link the "Reservation requests awaiting approval" dashboard notification to `/reservations?tab=manage`. When a shop owner opens that link, Reservations SHALL show the shop-management section (Manage Shops on mobile, Manage my Shops on web) with the pending requests section selected. Opening `/reservations` without `tab=manage` SHALL keep the current personal-requests landing.

#### Scenario: Shop owner opens the pending-requests notification

- **WHEN** a shop owner taps the "Reservation requests awaiting approval" notification
- **THEN** Reservations opens on the shop-management section with pending requests selected

#### Scenario: Reservations without the manage tab parameter

- **WHEN** a shop owner opens `/reservations` with no `tab` query parameter
- **THEN** Reservations opens on the personal requests section

### Requirement: New reviews notification opens the recent-reviews shops view

The system SHALL link the "New reviews in the last 30 days" dashboard notification to `/shops?recentReviews=30`. The notification count SHALL remain the number of reviews in the last 30 days across the same shop scope the dashboard uses today.

#### Scenario: Shop owner opens the new-reviews notification

- **WHEN** a shop owner taps the "New reviews in the last 30 days" notification
- **THEN** the shops list opens with the recent-reviews view for the last 30 days

### Requirement: Shop list reports recent review counts

Each shop in the shops list response SHALL include `recentReviewCount`, the number of reviews for that shop whose review date is within the last 30 days. Shops with no such reviews SHALL report `recentReviewCount` as 0. Existing `reviewCount` and `averageRating` fields SHALL remain unchanged.

#### Scenario: Shop with reviews in the last 30 days

- **WHEN** a shop has two reviews dated within the last 30 days and an average rating
- **THEN** its list item includes `recentReviewCount` of 2 and the existing average rating

#### Scenario: Shop with no recent reviews

- **WHEN** a shop has no reviews dated within the last 30 days
- **THEN** its list item includes `recentReviewCount` of 0

### Requirement: Recent-reviews view marks the shops the notification refers to

While the shops list is opened with `recentReviews=30`, each shop whose `recentReviewCount` is greater than 0 SHALL show its average rating and a badge of that recent count. Those shops SHALL sort ahead of shops with `recentReviewCount` of 0. Shops with `recentReviewCount` of 0 SHALL NOT show a recent-review badge and SHALL keep the existing unrated label when they have no reviews. The list SHALL show a dismissible indicator that the recent-reviews view is active. Dismissing it SHALL remove `recentReviews` from the view and restore the normal shop order without recent-review badges.

#### Scenario: Rated shop with new reviews is marked

- **WHEN** the shops list is opened with `recentReviews=30` and a shop has a recent review count greater than 0 and an average rating
- **THEN** that shop shows its average rating and a badge of the recent count, and it appears before shops with no recent reviews

#### Scenario: Shop with no recent reviews is unmarked

- **WHEN** the shops list is opened with `recentReviews=30` and a shop has `recentReviewCount` of 0 and no reviews
- **THEN** that shop shows no recent-review badge and shows the existing unrated label

#### Scenario: Dismissing the recent-reviews view

- **WHEN** the user dismisses the recent-reviews indicator
- **THEN** the shops list returns to its normal order and shops do not show recent-review badges
