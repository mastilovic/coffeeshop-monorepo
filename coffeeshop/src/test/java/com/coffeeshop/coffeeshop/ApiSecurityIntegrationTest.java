package com.coffeeshop.coffeeshop;

import com.coffeeshop.coffeeshop.auth.KeycloakAdminClient;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.resttestclient.TestRestTemplate;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureTestRestTemplate;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

import java.util.Map;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.when;

@SpringBootTest(
        webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
        properties = "spring.jpa.hibernate.ddl-auto=create-drop")
@AutoConfigureTestRestTemplate
@Import(TestcontainersConfiguration.class)
class ApiSecurityIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @MockitoBean
    private KeycloakAdminClient keycloakAdminClient;

    @Test
    void getUsers_withoutBearer_isOk() {
        final ResponseEntity<String> response = restTemplate.getForEntity("/api/v1/user", String.class);
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
    }

    @Test
    void postUser_withoutBearer_isUnauthorized() {
        final HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        final ResponseEntity<Void> response = restTemplate.exchange(
                "/api/v1/user",
                HttpMethod.POST,
                new HttpEntity<>(
                        Map.of(
                                "name", "A",
                                "email", "a@b.com",
                                "password", "x",
                                "userType", "CUSTOMER"),
                        headers),
                Void.class);
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);
    }

    @Test
    void register_withInvalidBearer_isCreated() {
        when(keycloakAdminClient.createUserWithRealmRole(anyString(), anyString(), anyString(), anyString()))
                .thenReturn(UUID.randomUUID());

        final HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth("not-a-valid-jwt");
        final ResponseEntity<Map> response = restTemplate.postForEntity(
                "/register",
                new HttpEntity<>(
                        Map.of(
                                "name", "Register Bearer",
                                "email", "register-bearer@example.com",
                                "password", "secret",
                                "role", "customer"),
                        headers),
                Map.class);
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
    }

    @Test
    void postUser_withBearer_isCreated() {
        final HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth("test-token");
        final ResponseEntity<Map> response = restTemplate.postForEntity(
                "/api/v1/user",
                new HttpEntity<>(
                        Map.of(
                                "name", "B",
                                "email", "b@b.com",
                                "password", "x",
                                "userType", "CUSTOMER"),
                        headers),
                Map.class);
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
    }
}
