package com.coffeeshop.coffeeshop;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.resttestclient.TestRestTemplate;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureTestRestTemplate;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;

import java.util.List;
import java.util.Map;
import java.util.UUID;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(
        webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
        properties = "spring.jpa.hibernate.ddl-auto=create-drop")
@AutoConfigureTestRestTemplate
@Import(TestcontainersConfiguration.class)
class UserPaginationIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    void searchByName_returnsMatchingPage() {
        final HttpHeaders headers = authHeaders();
        createUser(headers, "Alice Paginated", "alice-paginated@example.com", "CUSTOMER");
        createUser(headers, "Bob Paginated", "bob-paginated@example.com", "CUSTOMER");

        final ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                "/api/v1/user?q=alice-paginated&page=0&size=10",
                HttpMethod.GET,
                new HttpEntity<>(headers),
                new ParameterizedTypeReference<>() {
                });

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody().get("totalElements")).isEqualTo(1);
        @SuppressWarnings("unchecked")
        final List<Map<String, Object>> content = (List<Map<String, Object>>) response.getBody().get("content");
        assertThat(content).hasSize(1);
        assertThat(content.get(0).get("name")).isEqualTo("Alice Paginated");
    }

    @Test
    void searchByEmail_returnsMatchingPage() {
        final HttpHeaders headers = authHeaders();
        createUser(headers, "Email Search User", "email-search-user@example.com", "CUSTOMER");

        final ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                "/api/v1/user?q=email-search-user&page=0&size=10",
                HttpMethod.GET,
                new HttpEntity<>(headers),
                new ParameterizedTypeReference<>() {
                });

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        @SuppressWarnings("unchecked")
        final List<Map<String, Object>> content = (List<Map<String, Object>>) response.getBody().get("content");
        assertThat(content).hasSize(1);
        assertThat(content.get(0).get("email")).isEqualTo("email-search-user@example.com");
    }

    @Test
    void paginatedWithoutQuery_returnsPage() {
        final HttpHeaders headers = authHeaders();
        createUser(headers, "Page User One", "page-user-one@example.com", "CUSTOMER");
        createUser(headers, "Page User Two", "page-user-two@example.com", "CUSTOMER");
        createUser(headers, "Page User Three", "page-user-three@example.com", "CUSTOMER");

        final ResponseEntity<Map<String, Object>> response = restTemplate.exchange(
                "/api/v1/user?page=0&size=2",
                HttpMethod.GET,
                new HttpEntity<>(headers),
                new ParameterizedTypeReference<>() {
                });

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        @SuppressWarnings("unchecked")
        final List<Map<String, Object>> content = (List<Map<String, Object>>) response.getBody().get("content");
        assertThat(content).hasSize(2);
        assertThat(response.getBody().get("size")).isEqualTo(2);
        assertThat((Integer) response.getBody().get("totalPages")).isGreaterThanOrEqualTo(2);
    }

    @Test
    void getAllWithoutPage_returnsArray() {
        final HttpHeaders headers = authHeaders();
        createUser(headers, "Unpaginated User", "unpaginated-user@example.com", "CUSTOMER");

        final ResponseEntity<List> response = restTemplate.exchange(
                "/api/v1/user",
                HttpMethod.GET,
                new HttpEntity<>(headers),
                List.class);

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotNull();
        assertThat(response.getBody()).isInstanceOf(List.class);
    }

    private HttpHeaders authHeaders() {
        final HttpHeaders headers = new HttpHeaders();
        headers.setContentType(MediaType.APPLICATION_JSON);
        headers.setBearerAuth("integration-test-token");
        return headers;
    }

    private UUID createUser(
            final HttpHeaders headers,
            final String name,
            final String email,
            final String userType) {
        final ResponseEntity<Map> response = restTemplate.postForEntity(
                "/api/v1/user",
                new HttpEntity<>(Map.of(
                        "name", name,
                        "email", email,
                        "password", "secret",
                        "userType", userType), headers),
                Map.class);
        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.CREATED);
        return UUID.fromString(response.getBody().get("id").toString());
    }
}
