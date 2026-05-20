package com.coffeeshop.coffeeshop.auth;

import jakarta.validation.constraints.Email;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Pattern;

public record RegisterRequest(
        @NotBlank String name,
        @NotBlank @Email String email,
        @NotBlank String password,
        @NotBlank
        @Pattern(regexp = "customer|shop_owner", message = "role must be customer or shop_owner")
        String role
) {
}
