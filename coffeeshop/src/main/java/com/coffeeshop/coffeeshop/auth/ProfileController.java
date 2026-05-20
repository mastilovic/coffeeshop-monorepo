package com.coffeeshop.coffeeshop.auth;

import com.coffeeshop.coffeeshop.mapper.UserMapper;
import com.coffeeshop.coffeeshop.model.dto.response.UserProfileResponseDto;
import org.springframework.http.ResponseEntity;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.CrossOrigin;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RestController;

@RestController
@CrossOrigin(origins = "*")
public class ProfileController {

    private final CurrentUserService currentUserService;
    private final UserMapper userMapper;

    public ProfileController(final CurrentUserService currentUserService, final UserMapper userMapper) {
        this.currentUserService = currentUserService;
        this.userMapper = userMapper;
    }

    @GetMapping("/profile")
    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    public ResponseEntity<UserProfileResponseDto> profile() {
        return ResponseEntity.ok(userMapper.toUserProfileResponse(currentUserService.requireCurrentUser()));
    }
}
