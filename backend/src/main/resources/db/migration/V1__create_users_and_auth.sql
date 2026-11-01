-- V1: Core identity — users, refresh tokens, travel preferences

CREATE EXTENSION IF NOT EXISTS pgcrypto;

CREATE TABLE users (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name                VARCHAR(120)  NOT NULL,
    email               VARCHAR(255)  NOT NULL UNIQUE,
    password_hash       VARCHAR(255),                 -- nullable: OAuth-only users have no local password
    auth_provider       VARCHAR(20)   NOT NULL DEFAULT 'local'
                        CHECK (auth_provider IN ('local', 'google', 'apple')),
    profile_photo_url   TEXT,
    created_at          TIMESTAMPTZ   NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ   NOT NULL DEFAULT now()
);

CREATE TABLE refresh_tokens (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    token_hash      VARCHAR(255) NOT NULL,   -- SHA-256 of the raw token; never store the raw token
    expires_at      TIMESTAMPTZ  NOT NULL,
    revoked         BOOLEAN      NOT NULL DEFAULT false,
    created_at      TIMESTAMPTZ  NOT NULL DEFAULT now()
);

CREATE INDEX idx_refresh_tokens_user_id ON refresh_tokens(user_id);
CREATE INDEX idx_refresh_tokens_token_hash ON refresh_tokens(token_hash);

CREATE TABLE preferences (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    budget_range    VARCHAR(20) CHECK (budget_range IN ('budget', 'moderate', 'luxury')),
    travel_style    VARCHAR(30) CHECK (travel_style IN ('relaxed', 'adventure', 'cultural', 'family', 'solo', 'romantic')),
    interests       TEXT[],       -- e.g. {'hiking','food','museums'}
    updated_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

-- Shared trigger to keep updated_at honest on every UPDATE
CREATE OR REPLACE FUNCTION set_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = now();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TRIGGER trg_preferences_updated_at
    BEFORE UPDATE ON preferences
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();
