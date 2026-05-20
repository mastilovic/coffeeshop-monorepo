package com.coffeeshop.coffeeshop.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public record RegisterRequest(
        @NotBlank String name,
        @NotBlank
        @Pattern(regexp = "^[a-zA-Z0-9_]{3,30}$", message = "username must be 3-30 alphanumeric characters or underscores")
        String username,
        @NotBlank @Email String email,
        @NotBlank String password,
        @NotBlank
        @Pattern(regexp = "customer|shop_owner", message = "role must be customer or shop_owner")
        String role
) {
}
