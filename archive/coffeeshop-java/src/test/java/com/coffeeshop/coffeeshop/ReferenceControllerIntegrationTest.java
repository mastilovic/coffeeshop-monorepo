package com.coffeeshop.coffeeshop;

import org.junit.jupiter.api.Test;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.resttestclient.TestRestTemplate;
import org.springframework.boot.resttestclient.autoconfigure.AutoConfigureTestRestTemplate;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.context.annotation.Import;
import org.springframework.core.ParameterizedTypeReference;
import org.springframework.http.HttpMethod;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

@SpringBootTest(
        webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT,
        properties = "spring.jpa.hibernate.ddl-auto=create-drop")
@AutoConfigureTestRestTemplate
@Import(TestcontainersConfiguration.class)
class ReferenceControllerIntegrationTest {

    @Autowired
    private TestRestTemplate restTemplate;

    @Test
    void getSerbiaCities_returnsFullCatalog() {
        final ResponseEntity<List<String>> response = restTemplate.exchange(
                "/api/v1/reference/serbia-cities",
                HttpMethod.GET,
                null,
                new ParameterizedTypeReference<>() {});

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).isNotEmpty().contains("Beograd", "Novi Sad");
    }

    @Test
    void getSerbiaCities_withQuery_filtersResults() {
        final ResponseEntity<List<String>> response = restTemplate.exchange(
                "/api/v1/reference/serbia-cities?q=nov",
                HttpMethod.GET,
                null,
                new ParameterizedTypeReference<>() {});

        assertThat(response.getStatusCode()).isEqualTo(HttpStatus.OK);
        assertThat(response.getBody()).contains("Novi Sad");
    }
}
