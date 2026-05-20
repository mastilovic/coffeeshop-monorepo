package com.coffeeshop.coffeeshop.auth;

public class KeycloakAuthException extends RuntimeException {

    public KeycloakAuthException(final String message) {
        super(message);
    }

    public KeycloakAuthException(final String message, final Throwable cause) {
        super(message, cause);
    }
}
