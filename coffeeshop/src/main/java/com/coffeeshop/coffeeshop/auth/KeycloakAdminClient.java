package com.coffeeshop.coffeeshop.auth;

import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Component;
import org.springframework.util.LinkedMultiValueMap;
import org.springframework.util.MultiValueMap;
import org.springframework.web.client.HttpStatusCodeException;
import org.springframework.web.client.RestClient;

import java.net.URI;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

@Component
public class KeycloakAdminClient {

    private final KeycloakProperties properties;
    private final RestClient restClient = RestClient.create();

    public KeycloakAdminClient(final KeycloakProperties properties) {
        this.properties = properties;
    }

    /**
     * Deletes a realm user; ignores failures so callers can compensate without masking the original error.
     */
    public void deleteUserBestEffort(final UUID userId) {
        try {
            deleteUserBestEffort(userId, obtainAdminAccessToken());
        } catch (final KeycloakAuthException ignored) {
        }
    }

    private void deleteUserBestEffort(final UUID userId, final String adminBearerToken) {
        try {
            restClient.delete()
                    .uri(properties.adminUsersBaseUri() + "/" + userId)
                    .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminBearerToken)
                    .retrieve()
                    .toBodilessEntity();
        } catch (final HttpStatusCodeException ignored) {
        }
    }

    public UUID createUserWithRealmRole(
            final String email,
            final String password,
            final String name,
            final String realmRoleName) {
        final String adminToken = obtainAdminAccessToken();
        final Map<String, Object> payload = new HashMap<>();
        payload.put("username", email);
        payload.put("email", email);
        payload.put("firstName", name);
        payload.put("lastName", name);
        payload.put("enabled", true);
        payload.put("emailVerified", true);
        payload.put("credentials", List.of(Map.of(
                "type", "password",
                "value", password,
                "temporary", false)));

        final UUID userId;
        try {
            final var response = restClient.post()
                    .uri(properties.adminUsersBaseUri())
                    .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(payload)
                    .retrieve()
                    .toBodilessEntity();
            final URI location = response.getHeaders().getLocation();
            if (location == null) {
                throw new KeycloakAuthException("Keycloak user create response missing Location");
            }
            final String path = location.getPath();
            final String idSegment = path.substring(path.lastIndexOf('/') + 1);
            userId = UUID.fromString(idSegment);
        } catch (final HttpStatusCodeException ex) {
            if (ex.getStatusCode().value() == 409) {
                throw new KeycloakAuthException("User already exists in Keycloak", ex);
            }
            throw new KeycloakAuthException("Keycloak admin request failed: " + ex.getStatusCode(), ex);
        }

        try {
            final Map<String, Object> roleRep = restClient.get()
                    .uri(properties.adminRoleUri(realmRoleName))
                    .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                    .retrieve()
                    .body(new ParameterizedTypeReference<Map<String, Object>>() {
                    });
            if (roleRep == null) {
                throw new KeycloakAuthException("Realm role not found: " + realmRoleName);
            }
            restClient.post()
                    .uri(properties.adminUsersBaseUri() + "/" + userId + "/role-mappings/realm")
                    .header(HttpHeaders.AUTHORIZATION, "Bearer " + adminToken)
                    .contentType(MediaType.APPLICATION_JSON)
                    .body(List.of(roleRep))
                    .retrieve()
                    .toBodilessEntity();

            return userId;
        } catch (final HttpStatusCodeException ex) {
            deleteUserBestEffort(userId, adminToken);
            throw new KeycloakAuthException("Keycloak admin request failed: " + ex.getStatusCode(), ex);
        } catch (final KeycloakAuthException ex) {
            deleteUserBestEffort(userId, adminToken);
            throw ex;
        }
    }

    private String obtainAdminAccessToken() {
        final MultiValueMap<String, String> form = new LinkedMultiValueMap<>();
        form.add("grant_type", "password");
        form.add("client_id", "admin-cli");
        form.add("username", properties.getAdminUsername());
        form.add("password", properties.getAdminPassword());
        try {
            final Map<?, ?> body = restClient.post()
                    .uri(properties.adminTokenUri())
                    .contentType(MediaType.APPLICATION_FORM_URLENCODED)
                    .body(form)
                    .retrieve()
                    .body(Map.class);
            if (body == null || body.get("access_token") == null) {
                throw new KeycloakAuthException("Keycloak admin token missing access_token");
            }
            return body.get("access_token").toString();
        } catch (final HttpStatusCodeException ex) {
            throw new KeycloakAuthException("Keycloak admin login failed: " + ex.getStatusCode(), ex);
        }
    }
}
