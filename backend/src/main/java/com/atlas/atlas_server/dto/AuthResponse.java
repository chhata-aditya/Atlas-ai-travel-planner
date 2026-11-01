package com.atlas.atlas_server.dto;

import java.util.UUID;

public record AuthResponse(
        UUID userId,
        String name,
        String email,
        String accessToken,
        String refreshToken,
        String tokenType
) {
    public static AuthResponse of(UUID userId, String name, String email, String accessToken, String refreshToken) {
        return new AuthResponse(userId, name, email, accessToken, refreshToken, "Bearer");
    }
}
