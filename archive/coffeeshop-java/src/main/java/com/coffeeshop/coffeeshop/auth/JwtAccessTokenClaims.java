package com.coffeeshop.coffeeshop.auth;

import com.nimbusds.jwt.SignedJWT;
import org.springframework.stereotype.Component;

import java.util.Date;

@Component
public class JwtAccessTokenClaims {

    public String subject(final String accessToken) {
        try {
            return SignedJWT.parse(accessToken).getJWTClaimsSet().getSubject();
        } catch (final Exception e) {
            throw new IllegalStateException("Invalid access token", e);
        }
    }

    public String email(final String accessToken) {
        try {
            final String email = SignedJWT.parse(accessToken).getJWTClaimsSet().getStringClaim("email");
            if (email != null) {
                return email;
            }
            return SignedJWT.parse(accessToken).getJWTClaimsSet().getStringClaim("preferred_username");
        } catch (final Exception e) {
            throw new IllegalStateException("Invalid access token", e);
        }
    }

    public Boolean isTokenValid(final String accessToken) {
        try {
            Date expirationTime = SignedJWT.parse(accessToken).getJWTClaimsSet().getExpirationTime();
            return expirationTime.after(Date.from(java.time.Instant.now()));
        } catch (final Exception e) {
            throw new IllegalStateException("Invalid access token", e);
        }
    }
}
