package com.coffeeshop.coffeeshop.util;

import org.junit.jupiter.api.Test;

import java.time.LocalDateTime;

import static org.assertj.core.api.Assertions.assertThat;
import static org.assertj.core.api.Assertions.assertThatThrownBy;

class EventDateParserTest {

    @Test
    void parseOrThrow_parsesDateTimeLocalFormat() {
        assertThat(EventDateParser.parseOrThrow("2026-06-15T14:30"))
                .isEqualTo(LocalDateTime.of(2026, 6, 15, 14, 30));
    }

    @Test
    void parseOrThrow_parsesDateOnlyAsStartOfDay() {
        assertThat(EventDateParser.parseOrThrow("2026-06-15"))
                .isEqualTo(LocalDateTime.of(2026, 6, 15, 0, 0));
    }

    @Test
    void parseOrThrow_rejectsBlank() {
        assertThatThrownBy(() -> EventDateParser.parseOrThrow(" "))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("required");
    }

    @Test
    void parseOrThrow_rejectsInvalidFormat() {
        assertThatThrownBy(() -> EventDateParser.parseOrThrow("not-a-date"))
                .isInstanceOf(IllegalArgumentException.class)
                .hasMessageContaining("Invalid event date");
    }
}
