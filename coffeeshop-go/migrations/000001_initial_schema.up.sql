-- Baseline schema for fresh installs. Safe on existing Hibernate databases (IF NOT EXISTS).

CREATE TABLE IF NOT EXISTS roles (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY,
    name VARCHAR(255),
    username VARCHAR(255) UNIQUE,
    email VARCHAR(255),
    password VARCHAR(255),
    user_type VARCHAR(50),
    keycloak_subject VARCHAR(255) UNIQUE
);

CREATE TABLE IF NOT EXISTS user_role (
    user_id UUID NOT NULL REFERENCES users(id),
    role_id UUID NOT NULL REFERENCES roles(id),
    PRIMARY KEY (user_id, role_id)
);

CREATE TABLE IF NOT EXISTS shop (
    id UUID PRIMARY KEY,
    name VARCHAR(255),
    address VARCHAR(255),
    city VARCHAR(255),
    phone_number VARCHAR(255),
    email VARCHAR(255),
    current_menu_id UUID,
    loyalty_plan_id UUID
);

CREATE TABLE IF NOT EXISTS user_shop (
    id UUID PRIMARY KEY,
    user_id UUID NOT NULL,
    shop_id UUID NOT NULL,
    relationship_type VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS loyalty_plan (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(255),
    type VARCHAR(50) NOT NULL
);

CREATE TABLE IF NOT EXISTS menu (
    id UUID PRIMARY KEY,
    label VARCHAR(255),
    created_at TIMESTAMP,
    shop_id UUID NOT NULL,
    current BOOLEAN DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS menu_item (
    id UUID PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description VARCHAR(255),
    price DOUBLE PRECISION NOT NULL,
    price_currency VARCHAR(255) NOT NULL,
    image_url VARCHAR(255),
    item_type VARCHAR(50) NOT NULL,
    menu_id UUID NOT NULL
);

CREATE TABLE IF NOT EXISTS contacts (
    id UUID PRIMARY KEY,
    shop_id UUID NOT NULL
);

CREATE TABLE IF NOT EXISTS tables (
    id UUID PRIMARY KEY,
    number INTEGER NOT NULL,
    capacity INTEGER NOT NULL,
    shop_id UUID NOT NULL
);

CREATE TABLE IF NOT EXISTS event (
    event_id VARCHAR(255) PRIMARY KEY,
    event_name VARCHAR(255),
    event_date VARCHAR(255),
    description VARCHAR(255),
    shop_id UUID
);

CREATE TABLE IF NOT EXISTS review (
    id UUID PRIMARY KEY,
    title VARCHAR(255),
    description TEXT,
    rating INTEGER,
    review_date VARCHAR(255),
    comments_enabled BOOLEAN,
    user_id UUID,
    shop_id UUID
);

CREATE TABLE IF NOT EXISTS review_comment (
    id UUID PRIMARY KEY,
    body TEXT,
    created_at VARCHAR(255),
    user_id UUID,
    review_id UUID
);

CREATE TABLE IF NOT EXISTS community_post (
    id UUID PRIMARY KEY,
    body TEXT,
    created_at VARCHAR(255),
    type VARCHAR(50),
    pinned BOOLEAN DEFAULT FALSE,
    author_id UUID,
    shop_id UUID
);

CREATE TABLE IF NOT EXISTS reservation_request (
    id UUID PRIMARY KEY,
    party_size INTEGER,
    status VARCHAR(50),
    user_id UUID,
    shop_id UUID,
    event_id VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS reservations (
    id UUID PRIMARY KEY,
    party_size INTEGER,
    user_id UUID,
    shop_id UUID,
    table_id UUID,
    event_id VARCHAR(255),
    reservation_request_id UUID
);
