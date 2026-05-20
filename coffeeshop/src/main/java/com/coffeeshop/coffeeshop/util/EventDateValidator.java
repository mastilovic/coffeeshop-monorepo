package com.coffeeshop.coffeeshop.util;

import java.time.LocalDateTime;

public final class EventDateValidator {

    private EventDateValidator() {
    }

    public static void assertNotInPast(final String eventDate) {
        final LocalDateTime parsed = EventDateParser.parseOrThrow(eventDate);
        if (!parsed.isAfter(LocalDateTime.now())) {
            throw new IllegalArgumentException("Event date must be in the future");
        }
    }
}
