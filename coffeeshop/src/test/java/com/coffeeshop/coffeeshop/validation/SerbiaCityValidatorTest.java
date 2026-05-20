package com.coffeeshop.coffeeshop.validation;

import com.coffeeshop.coffeeshop.reference.SerbiaCityCatalog;
import jakarta.validation.ConstraintValidatorContext;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.io.IOException;

import static org.assertj.core.api.Assertions.assertThat;

@ExtendWith(MockitoExtension.class)
class SerbiaCityValidatorTest {

    @Mock
    private ConstraintValidatorContext context;

    private SerbiaCityValidator validator;

    @BeforeEach
    void setUp() throws IOException {
        validator = new SerbiaCityValidator(new SerbiaCityCatalog());
    }

    @Test
    void isValid_allowsCatalogCity() {
        assertThat(validator.isValid("Beograd", context)).isTrue();
    }

    @Test
    void isValid_rejectsUnknownCity() {
        assertThat(validator.isValid("Portland", context)).isFalse();
    }

    @Test
    void isValid_allowsNullOrBlank() {
        assertThat(validator.isValid(null, context)).isTrue();
        assertThat(validator.isValid("  ", context)).isTrue();
    }
}
