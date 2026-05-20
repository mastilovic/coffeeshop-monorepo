package com.coffeeshop.coffeeshop.validation;

import com.coffeeshop.coffeeshop.reference.SerbiaCityCatalog;
import jakarta.validation.ConstraintValidator;
import jakarta.validation.ConstraintValidatorContext;
import org.springframework.stereotype.Component;

@Component
public class SerbiaCityValidator implements ConstraintValidator<ValidSerbiaCity, String> {

    private final SerbiaCityCatalog serbiaCityCatalog;

    public SerbiaCityValidator(final SerbiaCityCatalog serbiaCityCatalog) {
        this.serbiaCityCatalog = serbiaCityCatalog;
    }

    @Override
    public boolean isValid(final String value, final ConstraintValidatorContext context) {
        if (value == null || value.isBlank()) {
            return true;
        }
        return serbiaCityCatalog.isAllowed(value);
    }
}
