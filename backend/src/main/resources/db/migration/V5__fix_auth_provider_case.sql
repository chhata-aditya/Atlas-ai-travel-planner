-- V5: Fix case mismatch — Hibernate's @Enumerated(EnumType.STRING) sends enum
-- constant names in UPPERCASE (e.g. "LOCAL"), but V1's constraint only allowed lowercase.

ALTER TABLE users DROP CONSTRAINT users_auth_provider_check;

ALTER TABLE users ADD CONSTRAINT users_auth_provider_check
    CHECK (auth_provider IN ('LOCAL', 'GOOGLE', 'APPLE'));
