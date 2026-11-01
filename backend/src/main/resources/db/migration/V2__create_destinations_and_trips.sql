-- V2: Destination catalog + trips + day-wise itinerary structure

CREATE TABLE destinations (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name            VARCHAR(150) NOT NULL,
    country         VARCHAR(100) NOT NULL,
    description     TEXT,
    hero_image_url  TEXT,
    category        VARCHAR(30) CHECK (category IN ('beach', 'mountain', 'city', 'cultural', 'adventure', 'island')),
    latitude        DECIMAL(9,6),
    longitude       DECIMAL(9,6),
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_destinations_country ON destinations(country);

CREATE TABLE trips (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id             UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    destination_id      UUID REFERENCES destinations(id) ON DELETE SET NULL,  -- nullable: user can plan a trip to somewhere not in the catalog yet
    destination_name    VARCHAR(150) NOT NULL,   -- always populated, even if destination_id is null (freeform)
    title               VARCHAR(150) NOT NULL,
    start_date          DATE NOT NULL,
    end_date            DATE NOT NULL,
    status              VARCHAR(20) NOT NULL DEFAULT 'planning'
                        CHECK (status IN ('planning', 'upcoming', 'ongoing', 'completed', 'cancelled')),
    cover_image_url     TEXT,
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    updated_at          TIMESTAMPTZ NOT NULL DEFAULT now(),
    CHECK (end_date >= start_date)
);

CREATE INDEX idx_trips_user_id ON trips(user_id);
CREATE INDEX idx_trips_status ON trips(status);

CREATE TRIGGER trg_trips_updated_at
    BEFORE UPDATE ON trips
    FOR EACH ROW EXECUTE FUNCTION set_updated_at();

CREATE TABLE itinerary_days (
    id              UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    trip_id         UUID NOT NULL REFERENCES trips(id) ON DELETE CASCADE,
    day_number      INT NOT NULL,
    day_date        DATE NOT NULL,
    created_at      TIMESTAMPTZ NOT NULL DEFAULT now(),
    UNIQUE (trip_id, day_number)
);

CREATE INDEX idx_itinerary_days_trip_id ON itinerary_days(trip_id);

CREATE TABLE activities (
    id                  UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    itinerary_day_id    UUID NOT NULL REFERENCES itinerary_days(id) ON DELETE CASCADE,
    title               VARCHAR(150) NOT NULL,
    description         TEXT,
    location_name       VARCHAR(200),
    latitude            DECIMAL(9,6),
    longitude           DECIMAL(9,6),
    start_time          TIME,
    end_time            TIME,
    category            VARCHAR(20) NOT NULL DEFAULT 'activity'
                        CHECK (category IN ('sightseeing', 'food', 'transport', 'accommodation', 'activity', 'shopping', 'other')),
    order_index         INT NOT NULL DEFAULT 0,   -- ordering within the day, independent of start_time gaps
    safety_tag          VARCHAR(20) CHECK (safety_tag IN ('low_crowd', 'moderate_crowd', 'high_crowd', 'caution')),
    created_at          TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_activities_itinerary_day_id ON activities(itinerary_day_id);
