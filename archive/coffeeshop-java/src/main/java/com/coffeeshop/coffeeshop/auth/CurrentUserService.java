package com.coffeeshop.coffeeshop.auth;

import com.coffeeshop.coffeeshop.model.User;
import com.coffeeshop.coffeeshop.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.Authentication;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.security.oauth2.server.resource.authentication.JwtAuthenticationToken;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

import java.util.Optional;

@Service
public class CurrentUserService {

    private final UserRepository userRepository;

    public CurrentUserService(final UserRepository userRepository) {
        this.userRepository = userRepository;
    }

    public User requireCurrentUser() {
        return getCurrentUser()
                .orElseThrow(() -> {
                    final Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
                    if (!(authentication instanceof JwtAuthenticationToken)) {
                        return new ResponseStatusException(HttpStatus.UNAUTHORIZED, "Bearer token required");
                    }
                    return new ResponseStatusException(
                            HttpStatus.NOT_FOUND,
                            "No local profile linked to this account; complete registration first");
                });
    }

    public Optional<User> getCurrentUser() {
        final Authentication authentication = SecurityContextHolder.getContext().getAuthentication();
        if (!(authentication instanceof final JwtAuthenticationToken jwtAuth)) {
            return Optional.empty();
        }
        final String sub = jwtAuth.getToken().getSubject();
        return userRepository.findByKeycloakSubject(sub);
    }
}
