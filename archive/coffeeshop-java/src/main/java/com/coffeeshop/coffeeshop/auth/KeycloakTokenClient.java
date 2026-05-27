package com.coffeeshop.coffeeshop.auth;

import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.RestClient;

import java.util.Map;

@Component
public class KeycloakTokenClient {

    private final KeycloakProperties properties;
    private final RestClient restClient = RestClient.create();

    public KeycloakTokenClient(final KeycloakProperties properties) {
        this.properties = properties;
    }

    public TokenResponse passwordGrant(final String email, final String password) {
        final MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
        form.add("grant_type", "password");
        form.add("client_id", properties.getClientId());
        form.add("client_secret", properties.getClientSecret());
        form.add("username", email);
        form.add("password", password);
        return postToken(form);
    }

    public TokenResponse refreshGrant(final String refreshToken) {
        final MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
        form.add("grant_type", "refresh_token");
        form.add("client_id", properties.getClientId());
        form.add("client_secret", properties.getClientSecret());
        form.add("refresh_token", refreshToken);
        return postToken(form);
    }

    public void logout(final String refreshToken) {
        final MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
        form.add("client_id", properties.getClientId());
        form.add("client_secret", properties.getClientSecret());
        form.add("refresh_token", refreshToken);
        try {
            restClient.post()
                    .uri(properties.logoutUri())
                    .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                    .body(form)
                    .retrieve()
                    .toBodilessEntity();
        } catch (final HttpStatusCodeException ex) {
            throw new KeycloakAuthException("Keycloak logout failed: " + ex.getStatusCode(), ex);
        }
    }

    private TokenResponse postToken(final MultiValueMap<String, String> form) {
        try {
            final Map<?, ?> body = restClient.post()
                    .uri(properties.tokenUri())
                    .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                    .body(form)
                    .retrieve()
                    .body(Map.class);
            if (body == null || body.get("access_token") == null) {
                throw new KeycloakAuthException("Keycloak token response missing access_token");
            }
            final String tokenType = body.get("token_type") != null ? body.get("token_type").toString() : "Bearer";
            final Number expires = (Number) body.get("expires_in");
            final long expiresIn = expires != null ? expires.longValue() : 0L;
            return new TokenResponse(
                    body.get("access_token").toString(),
                    body.get("refresh_token") != null ? body.get("refresh_token").toString() : "",
                    expiresIn,
                    tokenType
            );
        } catch (final HttpStatusCodeException ex) {
            throw new KeycloakAuthException("Keycloak token request failed: " + ex.getStatusCode(), ex);
        }
    }
}
