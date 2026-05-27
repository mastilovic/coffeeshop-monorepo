package com.coffeeshop.coffeeshop.reference;

import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import java.io.IOException;

import static org.assertj.core.api.Assertions.assertThat;

class SerbiaCityCatalogTest {

    private SerbiaCityCatalog catalog;

    @BeforeEach
    void setUp() throws IOException {
        catalog = new SerbiaCityCatalog();
    }

    @Test
    void getAll_returnsNonEmptySortedCatalog() {
        assertThat(catalog.getAll()).isNotEmpty().contains("Beograd", "Novi Sad");
    }

    @Test
    void isAllowed_acceptsCanonicalNames() {
        assertThat(catalog.isAllowed("Beograd")).isTrue();
        assertThat(catalog.isAllowed("  Novi Sad  ")).isTrue();
        assertThat(catalog.isAllowed("Novi Sad")).isTrue();
    }

    @Test
    void isAllowed_rejectsUnknownCity() {
        assertThat(catalog.isAllowed("Portland")).isFalse();
        assertThat(catalog.isAllowed(null)).isFalse();
    }

    @Test
    void search_filtersBySubstringIgnoringCaseAndDiacritics() {
        assertThat(catalog.search("nov")).contains("Novi Sad", "Novi Pazar");
        assertThat(catalog.search("NIS")).contains("Niš");
        assertThat(catalog.search("nis")).contains("Niš");
        assertThat(catalog.search("indjija")).contains("Inđija");
        assertThat(catalog.search("cacak")).contains("Čačak");
    }

    @Test
    void search_blankQueryReturnsAll() {
        assertThat(catalog.search("")).hasSize(catalog.getAll().size());
        assertThat(catalog.search(null)).hasSize(catalog.getAll().size());
    }
}
