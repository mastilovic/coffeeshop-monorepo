package com.coffeeshop.coffeeshop.auth;

import com.coffeeshop.coffeeshop.model.User;
import com.coffeeshop.coffeeshop.repository.UserRepository;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

@Service
public class AuthService {

    private final KeycloakTokenClient tokenClient;
    private final JwtAccessTokenClaims jwtAccessTokenClaims;
    private final UserRepository userRepository;

    public AuthService(
            final KeycloakTokenClient tokenClient,
            final JwtAccessTokenClaims jwtAccessTokenClaims,
            final UserRepository userRepository) {
        this.tokenClient = tokenClient;
        this.jwtAccessTokenClaims = jwtAccessTokenClaims;
        this.userRepository = userRepository;
    }

    @Transactional
    public TokenResponse login(final LoginRequest request) {
        final TokenResponse tokens = tokenClient.passwordGrant(request.email(), request.password());
        linkUserIfNeeded(tokens.accessToken());
        return tokens;
    }

    public TokenResponse refresh(final RefreshTokenRequest request) {
        return tokenClient.refreshGrant(request.refreshToken());
    }

    public void logout(final LogoutRequest request) {
        tokenClient.logout(request.refreshToken());
    }

    private void linkUserIfNeeded(final String accessToken) {
        final String sub = jwtAccessTokenClaims.subject(accessToken);
        if (userRepository.findByKeycloakSubject(sub).isPresent()) {
            return;
        }
        final String email = jwtAccessTokenClaims.email(accessToken);
        if (email == null) {
            return;
        }
        final User user = userRepository.findByEmailIgnoreCase(email).orElse(null);
        if (user != null && user.getKeycloakSubject() == null) {
            user.setKeycloakSubject(sub);
            userRepository.save(user);
        }
    }
}
