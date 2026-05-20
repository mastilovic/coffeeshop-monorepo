package com.coffeeshop.coffeeshop.util;

import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;

import static org.assertj.core.api.Assertions.assertThatCode;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class EventDateValidatorTest {

    private static final DateTimeFormatter FORMAT = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");

    @Test
    void assertNotInPast_allowsFutureDate() {
        final String future = LocalDateTime.now().plusDays(1).format(FORMAT);
        assertThatCode(() -> EventDateValidator.assertNotInPast(future))
                .doesNotThrowAnyException();
    }

    @Test
    void assertNotInPast_rejectsPastDate() {
        final String past = LocalDateTime.now().minusDays(1).format(FORMAT);
        assertThatThrownBy(() -> EventDateValidator.assertNotInPast(past))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessage("Event date must be in the future");
    }
}
