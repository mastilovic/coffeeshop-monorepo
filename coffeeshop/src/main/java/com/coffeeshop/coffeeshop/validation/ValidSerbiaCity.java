package com.coffeeshop.coffeeshop.validation;

import jakarta.validation.Constraint;
import jakarta.validation.Payload;

import java.lang.annotation.*;

@Documented
@Constraint(validatedBy = SerbiaCityValidator.class)
@Target({ElementType.FIELD, ElementType.PARAMETER})
@Retention(RetentionPolicy.RUNTIME)
public @interface ValidSerbiaCity {

    String message() default "City must be a valid city or town in Serbia";

    Class<?>[] groups() default {};

    Class<? extends Payload>[] payload() default {};
}
