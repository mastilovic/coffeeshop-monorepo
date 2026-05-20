package com.coffeeshop.coffeeshop.util;

import java.util.regex.Pattern;

public final class UsernameValidator {

    private static final Pattern USERNAME_PATTERN = Pattern.compile("^[a-zA-Z0-9_]{3,30}$");

    private UsernameValidator() {
    }

    public static void requireValid(final String username) {
        if (username == null || username.isBlank()) {
            throw new IllegalArgumentException("Username is required");
        }
        if (!USERNAME_PATTERN.matcher(username).matches()) {
            throw new IllegalArgumentException(
                    "Username must be 3-30 characters and contain only letters, numbers, and underscores");
        }
    }
}
