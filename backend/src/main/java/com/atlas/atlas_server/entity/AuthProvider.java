package com.atlas.atlas_server.entity;

/**
 * Mirrors the CHECK constraint on users.auth_provider in V1__create_users_and_auth.sql.
 * If you add a new provider, update BOTH this enum and that constraint.
 */
public enum AuthProvider {
    LOCAL,
    GOOGLE,
    APPLE
}
