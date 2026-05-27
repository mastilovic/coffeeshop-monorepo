# Tech stack

frontend: htmx
backend: fastapi
database: postgres
security: keycloak
when designing chat use valkey (in-memory database)

when designing UI use Tailwind CSS

For testing use pytest

Create Dockerfile and docker-compose for local development

When designing UI follow the principle of simplicity and usability, i want to be able to use the app without thinking too much.

Use simple darker colors that are easy to look at. Design should be modern and elegant. Users should feel comfortable using the app.

I also want to create mobile app for this project, so when designing keep in mind that it should be mobile friendly.

Mobile tech stack:
kotlin multiplatform
jetpack compose
for styling follow tailwind css approach
for https use okhttp
for jwt token handling use koin

# Routing
Routing for backend is supposed to be on /api/backend

## Frontend routing patterns
- **Public endpoints** (no auth required): `/auth/login`, `/auth/callback`, `/auth/logout`, `/auth/group-membership-required`, `/set-language`, `/health`, `/version`, `/static/*`


# Coffee Shop Template

User creation / personal info
Register (user or coffee shop, can register via google or email) / Login
Coffee shop chat (each coffee shop has its own chat room where users can chat with each other and the coffee shop staff)
Reservations (user can request reservations for tables, coffee shop can approve/deny, user can review history of reservations, coffee shop can cancel reservations, coffee shop can set capacity for each table and max number of reservations)

Tables (number of people per table)

Each coffee shop creates its own tables

User can equest reservation

Loyalty program (e.g. buy 10 coffees get 1 free, or similar)
Reviews (interactive gallery with other users)
Menu

should have gallery of photos of dish/drink, price and short description. Should have reviews and rating per dish/drink that audiance can review/rate.

Analytics (only for coffee shop owners - e.g. attendance, revenue, most popular dishes/drinks, etc.)
Subscription plans (for coffee shop owners to upgrade their subscription)
Merchandise (selling T-shirts, hoodies, etc.)

# Admin Panel

Reservations

Approve / deny

Email service

Tables

Can create tables for their coffee shop/restaurant

Notifications (publish events)

Select favorite restaurants you want to receive notifications from

If the notification is for a reservation or event, clicking it should redirect to the reservation form

Events

e.g. live music, quiz night

Admin notifications, push to all users (app updates, new features, etc.)

Tags (e.g. pet-friendly, parking, etc.)
Analytics (attendance, revenue, etc.)
Subscription
Contact us (for restaurants to contact support if they have issues)
Chat moderator

# Packages (i will provide the content for packages later, but i want you to design the packages page)

Free version
Standard
Gold
Platinum
Custom