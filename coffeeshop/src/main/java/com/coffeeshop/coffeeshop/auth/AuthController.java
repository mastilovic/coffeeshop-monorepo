package com.coffeeshop.coffeeshop.auth;

import com.coffeeshop.coffeeshop.model.dto.response.UserResponseDto;
import jakarta.validation.Valid;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RestController;

@RestController
@CrossOrigin(origins = "*")
public class AuthController {

    private final AuthService authService;
    private final RegistrationService registrationService;

    public AuthController(final AuthService authService, final RegistrationService registrationService) {
        this.authService = authService;
        this.registrationService = registrationService;
    }

    @PostMapping("/login")
    public TokenResponse login(@Valid @RequestBody final LoginRequest request) {
        return authService.login(request);
    }

    @PostMapping("/auth/login")
    public TokenResponse authLogin(@Valid @RequestBody final LoginRequest request) {
        return authService.login(request);
    }

    @PostMapping("/auth/refresh")
    public TokenResponse refresh(@Valid @RequestBody final RefreshTokenRequest request) {
        return authService.refresh(request);
    }

    @PostMapping("/auth/logout")
    public ResponseEntity<Void> logout(@Valid @RequestBody final LogoutRequest request) {
        authService.logout(request);
        return ResponseEntity.noContent().build();
    }

    @PostMapping("/register")
    public ResponseEntity<UserResponseDto> register(@Valid @RequestBody final RegisterRequest request) {
        return new ResponseEntity<>(registrationService.register(request), HttpStatus.CREATED);
    }
}
