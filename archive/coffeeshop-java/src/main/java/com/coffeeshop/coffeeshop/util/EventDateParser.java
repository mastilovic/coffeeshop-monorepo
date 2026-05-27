package com.coffeeshop.coffeeshop.util;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.time.format.DateTimeParseException;

public final class EventDateParser {

    private static final DateTimeFormatter DATE_TIME = DateTimeFormatter.ofPattern("yyyy-MM-dd'T'HH:mm");
    private static final DateTimeFormatter DATE = DateTimeFormatter.ISO_LOCAL_DATE;

    private EventDateParser() {
    }

    public static LocalDateTime parseOrThrow(final String eventDate) {
        if (eventDate == null || eventDate.isBlank()) {
            throw new IllegalArgumentException("Event date is required");
        }
        final String trimmed = eventDate.trim();
        try {
            if (trimmed.contains("T")) {
                return LocalDateTime.parse(trimmed, DATE_TIME);
            }
            return LocalDate.parse(trimmed, DATE).atStartOfDay();
        } catch (final DateTimeParseException ex) {
            throw new IllegalArgumentException("Invalid event date format: " + eventDate);
        }
    }
}
