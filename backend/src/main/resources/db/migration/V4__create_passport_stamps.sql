-- V4: Passport / visa stamp book (ProfileScreen -> AtlasPassportBook)

CREATE TABLE passport_stamps (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id         UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    trip_id         UUID REFERENCES trips(id) ON DELETE SET NULL,  -- nullable: custom stamps aren't tied to a trip
    country_name    VARCHAR(100) NOT NULL,
    airport_code    VARCHAR(4),        -- e.g. NRT, DPS, ZRH, CDG
    stamp_type      VARCHAR(10) NOT NULL DEFAULT 'entry' CHECK (stamp_type IN ('entry', 'exit')),
    stamp_date      DATE NOT NULL DEFAULT CURRENT_DATE,
    is_custom       BOOLEAN NOT NULL DEFAULT false,  -- true = user manually added, false = auto-generated from a completed trip
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_passport_stamps_user_id ON passport_stamps(user_id);
CREATE INDEX idx_passport_stamps_trip_id ON passport_stamps(trip_id);

-- Note: drawer stats (Countries / Trips / Miles) are intentionally NOT stored columns —
-- compute them from trips + passport_stamps at query time (e.g. COUNT(DISTINCT country_name))
-- rather than maintaining denormalized counters that can drift out of sync.
