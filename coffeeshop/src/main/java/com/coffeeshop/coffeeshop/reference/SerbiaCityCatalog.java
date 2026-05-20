package com.coffeeshop.coffeeshop.reference;

import com.coffeeshop.coffeeshop.util.SearchTextNormalizer;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.core.io.ClassPathResource;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.util.List;

@Component
public class SerbiaCityCatalog {

    private static final String RESOURCE_PATH = "reference/serbia-cities.json";

    private final List<String> cities;

    public SerbiaCityCatalog() throws IOException {
        final ObjectMapper objectMapper = new ObjectMapper();
        try (var input = new ClassPathResource(RESOURCE_PATH).getInputStream()) {
            final List<String> loaded = objectMapper.readValue(input, new TypeReference<>() {});
            this.cities = List.copyOf(loaded);
        }
    }

    public List<String> getAll() {
        return cities;
    }

    public boolean isAllowed(final String city) {
        if (city == null) {
            return false;
        }
        final String trimmed = city.trim();
        return cities.stream().anyMatch(c -> c.equals(trimmed));
    }

    public List<String> search(final String query) {
        if (query == null || query.isBlank()) {
            return cities;
        }
        final String normalizedQuery = normalizeForSearch(query);
        return cities.stream()
                .filter(c -> normalizeForSearch(c).contains(normalizedQuery))
                .toList();
    }

    static String normalizeForSearch(final String value) {
        return SearchTextNormalizer.normalizeForSearch(value);
    }
}
