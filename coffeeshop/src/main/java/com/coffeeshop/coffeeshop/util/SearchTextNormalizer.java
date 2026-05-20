package com.coffeeshop.coffeeshop.util;

import java.text.Normalizer;
import java.util.Locale;

public final class SearchTextNormalizer {

    private SearchTextNormalizer() {
    }

    public static String normalizeForSearch(final String value) {
        if (value == null) {
            return "";
        }
        String normalized = value
                .replace("đ", "dj")
                .replace("Đ", "dj")
                .replace("č", "c")
                .replace("Č", "c")
                .replace("ć", "c")
                .replace("Ć", "c")
                .replace("š", "s")
                .replace("Š", "s")
                .replace("ž", "z")
                .replace("Ž", "z");
        normalized = normalized.toLowerCase(Locale.ROOT);
        final String decomposed = Normalizer.normalize(normalized, Normalizer.Form.NFD);
        return decomposed.replaceAll("\\p{M}+", "");
    }
}
