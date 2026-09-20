-- Owner subscription pricing catalog (Phase 1). Adjustable via admin UI; no payment tables yet.

CREATE TABLE IF NOT EXISTS plan_tier_catalog (
    tier VARCHAR(50) PRIMARY KEY,
    display_name VARCHAR(255) NOT NULL,
    base_price_monthly_cents INTEGER NOT NULL DEFAULT 0,
    extra_shop_price_cents INTEGER,
    annual_months_charged INTEGER NOT NULL DEFAULT 12,
    is_active BOOLEAN NOT NULL DEFAULT TRUE,
    updated_at TIMESTAMP NOT NULL DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS feature_catalog (
    feature_key VARCHAR(100) PRIMARY KEY,
    display_name VARCHAR(255) NOT NULL,
    description TEXT,
    monthly_price_cents INTEGER NOT NULL DEFAULT 0,
    limit_type VARCHAR(50),
    limit_value INTEGER,
    is_selectable_custom BOOLEAN NOT NULL DEFAULT TRUE,
    sort_order INTEGER NOT NULL DEFAULT 0,
    is_active BOOLEAN NOT NULL DEFAULT TRUE
);

CREATE TABLE IF NOT EXISTS plan_tier_features (
    tier VARCHAR(50) NOT NULL REFERENCES plan_tier_catalog(tier),
    feature_key VARCHAR(100) NOT NULL REFERENCES feature_catalog(feature_key),
    included BOOLEAN NOT NULL DEFAULT FALSE,
    PRIMARY KEY (tier, feature_key)
);

-- Preset tier pricing (admin-editable)
INSERT INTO plan_tier_catalog (tier, display_name, base_price_monthly_cents, extra_shop_price_cents, annual_months_charged, is_active, updated_at)
VALUES
    ('STARTER', 'Starter', 0, NULL, 12, TRUE, NOW()),
    ('GROWTH', 'Growth', 2900, 1500, 10, TRUE, NOW()),
    ('PRO', 'Pro', 7900, 1000, 10, TRUE, NOW());

-- Feature catalog with custom à-la-carte prices and limit metadata (admin-editable)
INSERT INTO feature_catalog (feature_key, display_name, description, monthly_price_cents, limit_type, limit_value, is_selectable_custom, sort_order, is_active)
VALUES
    ('reservation_manage', 'Reservation management', 'Accept, deny, and assign tables for reservation requests', 800, NULL, NULL, TRUE, 10, TRUE),
    ('event_create', 'Events', 'Create and manage shop events', 1000, 'monthly_per_shop', 5, TRUE, 20, TRUE),
    ('employee_assign', 'Employees', 'Assign employees to shops', 600, 'per_shop', 3, TRUE, 30, TRUE),
    ('community_post', 'Community posts', 'Post announcements and manage community members', 500, NULL, NULL, TRUE, 40, TRUE),
    ('loyalty_basic', 'Loyalty (Basic)', 'Customer loyalty program — BASIC tier only', 1200, 'loyalty_tier', NULL, TRUE, 50, TRUE),
    ('loyalty_premium', 'Loyalty (Premium/VIP)', 'Customer loyalty program — PREMIUM and VIP tiers', 2000, 'loyalty_tier', NULL, TRUE, 60, TRUE),
    ('review_moderate', 'Review moderation', 'Moderate and delete reviews on owned shops', 400, NULL, NULL, TRUE, 70, TRUE),
    ('dashboard_notifications', 'Dashboard notifications', 'Owner notifications for pending requests and new reviews', 300, NULL, NULL, TRUE, 80, TRUE),
    ('analytics', 'Analytics', 'Full dashboard analytics and reporting', 1500, NULL, NULL, TRUE, 90, TRUE),
    ('unlimited_tables', 'Unlimited tables', 'Remove table count cap (Starter default: 15 per shop)', 500, 'max_per_shop', 15, TRUE, 100, TRUE),
    ('unlimited_menus', 'Unlimited menus', 'Remove menu count cap (Starter default: 1 per shop)', 500, 'max_per_shop', 1, TRUE, 110, TRUE);

-- Tier-feature bundle matrix
INSERT INTO plan_tier_features (tier, feature_key, included)
VALUES
    -- Starter: no paid features; capped tables/menus via absence of unlimited_* features
    ('STARTER', 'reservation_manage', FALSE),
    ('STARTER', 'event_create', FALSE),
    ('STARTER', 'employee_assign', FALSE),
    ('STARTER', 'community_post', FALSE),
    ('STARTER', 'loyalty_basic', FALSE),
    ('STARTER', 'loyalty_premium', FALSE),
    ('STARTER', 'review_moderate', FALSE),
    ('STARTER', 'dashboard_notifications', FALSE),
    ('STARTER', 'analytics', FALSE),
    ('STARTER', 'unlimited_tables', FALSE),
    ('STARTER', 'unlimited_menus', FALSE),

    -- Growth: operations bundle without analytics or premium loyalty
    ('GROWTH', 'reservation_manage', TRUE),
    ('GROWTH', 'event_create', TRUE),
    ('GROWTH', 'employee_assign', TRUE),
    ('GROWTH', 'community_post', TRUE),
    ('GROWTH', 'loyalty_basic', TRUE),
    ('GROWTH', 'loyalty_premium', FALSE),
    ('GROWTH', 'review_moderate', TRUE),
    ('GROWTH', 'dashboard_notifications', TRUE),
    ('GROWTH', 'analytics', FALSE),
    ('GROWTH', 'unlimited_tables', TRUE),
    ('GROWTH', 'unlimited_menus', TRUE),

    -- Pro: all features
    ('PRO', 'reservation_manage', TRUE),
    ('PRO', 'event_create', TRUE),
    ('PRO', 'employee_assign', TRUE),
    ('PRO', 'community_post', TRUE),
    ('PRO', 'loyalty_basic', TRUE),
    ('PRO', 'loyalty_premium', TRUE),
    ('PRO', 'review_moderate', TRUE),
    ('PRO', 'dashboard_notifications', TRUE),
    ('PRO', 'analytics', TRUE),
    ('PRO', 'unlimited_tables', TRUE),
    ('PRO', 'unlimited_menus', TRUE);

-- Owner subscription state (Phase 2). Payment columns deferred to a later phase.
-- New SHOP_OWNER accounts default to STARTER via application hook (Phase 3+); not enforced here.

CREATE TABLE IF NOT EXISTS owner_subscription (
    user_id UUID PRIMARY KEY REFERENCES users(id) ON DELETE CASCADE,
    plan_mode VARCHAR(20) NOT NULL CHECK (plan_mode IN ('PRESET', 'CUSTOM')),
    plan_tier VARCHAR(50) REFERENCES plan_tier_catalog(tier),
    status VARCHAR(50) NOT NULL,
    billing_interval VARCHAR(20) CHECK (billing_interval IN ('monthly', 'annual')),
    locked_monthly_amount_cents INTEGER,
    current_period_start TIMESTAMP,
    current_period_end TIMESTAMP,
    canceled_at TIMESTAMP,
    CONSTRAINT owner_subscription_preset_requires_tier
        CHECK (plan_mode = 'CUSTOM' OR plan_tier IS NOT NULL)
);

CREATE TABLE IF NOT EXISTS owner_subscription_features (
    user_id UUID NOT NULL REFERENCES owner_subscription(user_id) ON DELETE CASCADE,
    feature_key VARCHAR(100) NOT NULL REFERENCES feature_catalog(feature_key),
    PRIMARY KEY (user_id, feature_key)
);

CREATE TABLE IF NOT EXISTS shop_subscription (
    shop_id UUID PRIMARY KEY REFERENCES shop(id) ON DELETE CASCADE,
    owner_user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    is_base_shop BOOLEAN NOT NULL DEFAULT FALSE
);

CREATE TABLE IF NOT EXISTS shop_usage (
    shop_id UUID NOT NULL REFERENCES shop(id) ON DELETE CASCADE,
    period_start DATE NOT NULL,
    events_created INTEGER NOT NULL DEFAULT 0,
    PRIMARY KEY (shop_id, period_start)
);

-- Grandfather existing shop owners onto Growth (test/sample accounts). No payment fields yet.
INSERT INTO owner_subscription (user_id, plan_mode, plan_tier, status, billing_interval)
SELECT id, 'PRESET', 'GROWTH', 'active', 'monthly'
FROM users
WHERE user_type = 'SHOP_OWNER';

-- Link owned shops; first shop per owner is the included base shop (shop has no created_at — order by id).
INSERT INTO shop_subscription (shop_id, owner_user_id, is_base_shop)
SELECT us.shop_id,
       us.user_id,
       ROW_NUMBER() OVER (PARTITION BY us.user_id ORDER BY s.id) = 1
FROM user_shop us
JOIN shop s ON s.id = us.shop_id
WHERE us.relationship_type = 'OWNER';
