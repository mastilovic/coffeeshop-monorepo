package com.coffeeshop.coffeeshop.util;

import org.junit.jupiter.api.Test;

import static org.assertj.core.api.Assertions.assertThat;

class SearchTextNormalizerTest {

    @Test
    void normalizeForSearch_mapsSerbianLatinCharacters() {
        assertThat(SearchTextNormalizer.normalizeForSearch("đ")).isEqualTo("dj");
        assertThat(SearchTextNormalizer.normalizeForSearch("Đ")).isEqualTo("dj");
        assertThat(SearchTextNormalizer.normalizeForSearch("č")).isEqualTo("c");
        assertThat(SearchTextNormalizer.normalizeForSearch("ć")).isEqualTo("c");
        assertThat(SearchTextNormalizer.normalizeForSearch("š")).isEqualTo("s");
        assertThat(SearchTextNormalizer.normalizeForSearch("ž")).isEqualTo("z");
    }

    @Test
    void normalizeForSearch_normalizesCityNames() {
        assertThat(SearchTextNormalizer.normalizeForSearch("Niš")).isEqualTo("nis");
        assertThat(SearchTextNormalizer.normalizeForSearch("NIS")).isEqualTo("nis");
        assertThat(SearchTextNormalizer.normalizeForSearch("Čačak")).isEqualTo("cacak");
        assertThat(SearchTextNormalizer.normalizeForSearch("Inđija")).isEqualTo("indjija");
        assertThat(SearchTextNormalizer.normalizeForSearch("Beograd")).isEqualTo("beograd");
    }

    @Test
    void normalizeForSearch_nullReturnsEmpty() {
        assertThat(SearchTextNormalizer.normalizeForSearch(null)).isEmpty();
    }
}
