package com.coffeeshop.coffeeshop;

import com.coffeeshop.coffeeshop.auth.KeycloakAdminClient;
import com.coffeeshop.coffeeshop.auth.KeycloakAuthException;
import com.coffeeshop.coffeeshop.auth.KeycloakTokenClient;
import com.coffeeshop.coffeeshop.model.User;
import com.coffeeshop.coffeeshop.model.enums.UserType;
import com.coffeeshop.coffeeshop.repository.UserRepository;
import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.resttestclient.TestRestTemplate;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureTestRestTemplate;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.test.context.bean.override.mockito.MockitoBean;

import java.util.Map;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;
import static org.mockito.ArgumentMatchers.anyString;
import static org.mockito.Mockito.never;
import static org.mockito.Mockito.verify;
import static org.mockito.Mockito.when;

@SpringBootTest(
        webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
        properties = "spring.jpa.hibernate.ddl-auto=create-drop")
@AutoConfigureTestRestTemplate
@Import(TestcontainersConfiguration.class)
class AuthIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Autowired
    private UserRepository userRepository;

    @MockitoBean
    private KeycloakTokenClient keycloakTokenClient;

    @MockitoBean
    private KeycloakAdminClient keycloakAdminClient;

    @Test
    void login_unknownEmail_returns404() {
        final HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        final ResponseEntity<Map> response = restTemplate.postForEntity(
                "/login",
                new HttpEntity<>(Map.of("email", "unknown@example.com", "password", "secret"), headers),
                Map.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
        assertThat(response.getBody()).containsEntry("message", "not found");
        verify(keycloakTokenClient, never()).passwordGrant(anyString(), anyString());
    }

    @Test
    void login_wrongPassword_returns401() {
        final User user = new User();
        user.setName("Login User");
        user.setEmail("login-wrong@example.com");
        user.setUserType(UserType.CUSTOMER);
        user.setKeycloakSubject(UUID.randomUUID().toString());
        userRepository.save(user);

        when(keycloakTokenClient.passwordGrant(anyString(), anyString()))
                .thenThrow(new KeycloakAuthException("Keycloak token request failed"));

        final HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        final ResponseEntity<Map> response = restTemplate.postForEntity(
                "/login",
                new HttpEntity<>(Map.of("email", "login-wrong@example.com", "password", "wrong"), headers),
                Map.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.UNAUTHORIZED);
        assertThat(response.getBody()).containsEntry("message", "Invalid email or password");
    }

    @Test
    void register_duplicateEmail_returns404() {
        when(keycloakAdminClient.createUserWithRealmRole(anyString(), anyString(), anyString(), anyString()))
                .thenReturn(UUID.randomUUID());

        final HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        final Map<String, String> body = Map.of(
                "name", "Dup User",
                "email", "dup@example.com",
                "password", "secret123",
                "role", "customer");

        final ResponseEntity<Map> first = restTemplate.postForEntity(
                "/register",
                new HttpEntity<>(body, headers),
                Map.class);
        assertThat(first.getStatusCode()).isEqualTo(HttpStatus.CREATED);

        final ResponseEntity<Map> second = restTemplate.postForEntity(
                "/register",
                new HttpEntity<>(body, headers),
                Map.class);

        assertThat(second.getStatusCode()).isEqualTo(HttpStatus.NOT_FOUND);
        assertThat(second.getBody())
                .containsEntry("message", "An account with this email already exists");
    }
}
