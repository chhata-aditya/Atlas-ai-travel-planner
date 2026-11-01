-- V3: Budget tracking + bookmarking (external places and catalog destinations)

CREATE TABLE budgets (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id         UUID NOT NULL UNIQUE REFERENCES trips(id) ON DELETE CASCADE,
    total_budget    DECIMAL(12,2) NOT NULL CHECK (total_budget >= 0),
    currency        CHAR(3) NOT NULL DEFAULT 'INR',   -- ISO 4217
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE TABLE expenses (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    budget_id       UUID NOT NULL REFERENCES budgets(id) ON DELETE CASCADE,
    category        VARCHAR(20) NOT NULL
                    CHECK (category IN ('stay', 'food', 'transport', 'activities', 'shopping', 'misc')),
    amount          DECIMAL(12,2) NOT NULL CHECK (amount >= 0),
    description     VARCHAR(200),
    expense_date    DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_expenses_budget_id ON expenses(budget_id);

-- Hotels / restaurants / POIs discovered via Google Places, bookmarked by a user.
-- Deliberately NOT tied to a single trip — the synopsis specifies these persist independently.
CREATE TABLE saved_places (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    place_name          VARCHAR(200) NOT NULL,
    google_place_id     VARCHAR(255),     -- reference back into Places API for fresh details/photos
    place_type          VARCHAR(20) NOT NULL CHECK (place_type IN ('hotel', 'restaurant', 'poi')),
    notes               TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_saved_places_user_id ON saved_places(user_id);

-- Bookmarking your own destinations catalog (Explore tab "favorite" action)
CREATE TABLE favorite_destinations (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    destination_id  UUID NOT NULL REFERENCES destinations(id) ON DELETE CASCADE,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (user_id, destination_id)
);

CREATE INDEX idx_favorite_destinations_user_id ON favorite_destinations(user_id);
