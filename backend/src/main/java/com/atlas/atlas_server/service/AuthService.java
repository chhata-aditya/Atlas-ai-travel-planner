package com.atlas.atlas_server.service;

import com.atlas.atlas_server.dto.AuthResponse;
import com.atlas.atlas_server.dto.LoginRequest;
import com.atlas.atlas_server.dto.OAuthLoginRequest;
import com.atlas.atlas_server.dto.RegisterRequest;
import com.atlas.atlas_server.entity.AuthProvider;
import com.atlas.atlas_server.entity.RefreshToken;
import com.atlas.atlas_server.entity.User;
import com.atlas.atlas_server.repository.RefreshTokenRepository;
import com.atlas.atlas_server.repository.UserRepository;
import com.atlas.atlas_server.security.JwtService;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpStatus;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.OffsetDateTime;

@Service
public class AuthService {

    private final UserRepository userRepository;
    private final RefreshTokenRepository refreshTokenRepository;
    private final PasswordEncoder passwordEncoder;
    private final JwtService jwtService;
    private final long refreshTokenExpiryDays;

    public AuthService(
            UserRepository userRepository,
            RefreshTokenRepository refreshTokenRepository,
            PasswordEncoder passwordEncoder,
            JwtService jwtService,
            @Value("${jwt.refresh-token-expiry-days}") long refreshTokenExpiryDays
    ) {
        this.userRepository = userRepository;
        this.refreshTokenRepository = refreshTokenRepository;
        this.passwordEncoder = passwordEncoder;
        this.jwtService = jwtService;
        this.refreshTokenExpiryDays = refreshTokenExpiryDays;
    }

    @Transactional
    public AuthResponse register(RegisterRequest request) {
        if (userRepository.existsByEmail(request.email())) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "An account with this email already exists");
        }

        User user = User.builder()
                .name(request.name())
                .email(request.email())
                .passwordHash(passwordEncoder.encode(request.password()))
                .authProvider(AuthProvider.LOCAL)
                .build();

        user = userRepository.save(user);
        return issueTokens(user);
    }

    @Transactional
    public AuthResponse login(LoginRequest request) {
        User user = userRepository.findByEmail(request.email())
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid email or password"));

        if (user.getPasswordHash() == null) {
            // Account was created via Google/Apple — no local password to check against.
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED,
                    "This account uses " + user.getAuthProvider() + " sign-in, not a password");
        }

        if (!passwordEncoder.matches(request.password(), user.getPasswordHash())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid email or password");
        }

        return issueTokens(user);
    }

    @Transactional
    public AuthResponse refresh(String rawRefreshToken) {
        String tokenHash = jwtService.hashRefreshToken(rawRefreshToken);

        RefreshToken stored = refreshTokenRepository.findByTokenHash(tokenHash)
                .orElseThrow(() -> new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Invalid refresh token"));

        if (stored.isRevoked() || stored.getExpiresAt().isBefore(OffsetDateTime.now())) {
            throw new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Refresh token expired or revoked");
        }

        // Rotate: revoke the old one, issue a brand new pair. Prevents a leaked refresh token from being reused forever.
        stored.setRevoked(true);
        refreshTokenRepository.save(stored);

        return issueTokens(stored.getUser());
    }

    @Transactional
    public AuthResponse oauthLogin(OAuthLoginRequest request) {
        String providerStr = request.provider().trim().toUpperCase();
        AuthProvider provider;
        if ("GOOGLE".equals(providerStr)) {
            provider = AuthProvider.GOOGLE;
        } else if ("APPLE".equals(providerStr)) {
            provider = AuthProvider.APPLE;
        } else {
            provider = AuthProvider.LOCAL;
        }

        String email = request.email().trim().toLowerCase();
        User user = userRepository.findByEmail(email).orElseGet(() -> {
            String displayName = request.name();
            if (displayName == null || displayName.isBlank()) {
                displayName = email.contains("@") ? email.substring(0, email.indexOf('@')) : "Traveler";
            }
            User newUser = User.builder()
                    .name(displayName)
                    .email(email)
                    .authProvider(provider)
                    .profilePhotoUrl(request.avatarUrl())
                    .build();
            return userRepository.save(newUser);
        });

        return issueTokens(user);
    }

    private AuthResponse issueTokens(User user) {
        String accessToken = jwtService.generateAccessToken(user.getId(), user.getEmail());
        String rawRefreshToken = jwtService.generateRawRefreshToken();

        RefreshToken refreshToken = RefreshToken.builder()
                .user(user)
                .tokenHash(jwtService.hashRefreshToken(rawRefreshToken))
                .expiresAt(OffsetDateTime.now().plusDays(refreshTokenExpiryDays))
                .revoked(false)
                .build();
        refreshTokenRepository.save(refreshToken);

        return AuthResponse.of(user.getId(), user.getName(), user.getEmail(), accessToken, rawRefreshToken);
    }
}
