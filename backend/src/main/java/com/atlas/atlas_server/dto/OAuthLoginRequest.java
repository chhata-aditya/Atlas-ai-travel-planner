package com.atlas.atlas_server.dto;

import jakarta.validation.constraints.NotBlank;

/**
 * Stub for Google/Apple sign-in. The Flutter app will get an ID token from the
 * Google/Apple SDK and send it here. Real verification of idToken against
 * Google/Apple's public keys is NOT implemented yet — see AuthService.oauthLoginStub().
 */
public record OAuthLoginRequest(
        @NotBlank(message = "Provider is required")
        String provider,   // "google", "apple", or "biometric"

        String idToken,

        @NotBlank(message = "Email is required")
        String email,

        String name,

        String avatarUrl
) {}

