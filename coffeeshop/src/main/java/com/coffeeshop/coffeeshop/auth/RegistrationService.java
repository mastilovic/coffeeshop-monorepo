package com.coffeeshop.coffeeshop.auth;

import com.coffeeshop.coffeeshop.exception.ResourceNotFoundException;
import com.coffeeshop.coffeeshop.mapper.UserMapper;
import com.coffeeshop.coffeeshop.model.User;
import com.coffeeshop.coffeeshop.model.dto.response.UserResponseDto;
import com.coffeeshop.coffeeshop.model.enums.UserType;
import com.coffeeshop.coffeeshop.repository.UserRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.CannotCreateTransactionException;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.net.UnknownHostException;
import java.sql.SQLException;
import java.util.UUID;

@Service
public class RegistrationService {

    private static final String DUPLICATE_EMAIL_MESSAGE = "An account with this email already exists";

    private final KeycloakAdminClient keycloakAdminClient;
    private final UserRepository userRepository;
    private final UserMapper userMapper;

    public RegistrationService(
            final KeycloakAdminClient keycloakAdminClient,
            final UserRepository userRepository,
            final UserMapper userMapper) {
        this.keycloakAdminClient = keycloakAdminClient;
        this.userRepository = userRepository;
        this.userMapper = userMapper;
    }

    @Transactional
    public UserResponseDto register(final RegisterRequest request) {
        if ("admin".equalsIgnoreCase(request.role())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "admin role is not allowed for self-registration");
        }
        if (userRepository.existsByEmailIgnoreCase(request.email())) {
            throw new ResourceNotFoundException(DUPLICATE_EMAIL_MESSAGE);
        }
        final UserType userType = switch (request.role()) {
            case "customer" -> UserType.CUSTOMER;
            case "shop_owner" -> UserType.SHOP_OWNER;
            default -> throw new ResponseStatusException(HttpStatus.UNPROCESSABLE_ENTITY, "Invalid role");
        };
        final UUID keycloakUserId;
        try {
            keycloakUserId = keycloakAdminClient.createUserWithRealmRole(
                    request.email(),
                    request.password(),
                    request.name(),
                    request.role());
        } catch (final KeycloakAuthException ex) {
            if (ex.getMessage() != null && ex.getMessage().contains("already exists")) {
                throw new ResourceNotFoundException(DUPLICATE_EMAIL_MESSAGE);
            }
            throw new ResponseStatusException(HttpStatus.BAD_GATEWAY, "Registration failed with identity provider", ex);
        }
        final User user = new User();
        user.setName(request.name());
        user.setEmail(request.email());
        user.setPassword(null);
        user.setUserType(userType);
        user.setKeycloakSubject(keycloakUserId.toString());
        try {
            return userMapper.toUserResponse(userRepository.save(user));
        } catch (final RuntimeException ex) {
            keycloakAdminClient.deleteUserBestEffort(keycloakUserId);
            throw ex;
        }
    }
}
