package com.coffeeshop.coffeeshop.repository;

import com.coffeeshop.coffeeshop.model.User;
import com.coffeeshop.coffeeshop.util.SearchTextNormalizer;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Expression;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.jpa.domain.Specification;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public final class UserSpecifications {

    private static final String[][] ASCII_REPLACEMENTS = {
            {"đ", "dj"},
            {"č", "c"},
            {"ć", "c"},
            {"š", "s"},
            {"ž", "z"},
    };

    private UserSpecifications() {
    }

    public static Specification<User> search(final Optional<String> query) {
        return (root, criteriaQuery, cb) -> {
            final List<Predicate> predicates = new ArrayList<>();

            final String normalized = query
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .map(SearchTextNormalizer::normalizeForSearch)
                    .orElse(null);

            if (normalized != null) {
                final String pattern = "%" + normalized + "%";
                predicates.add(cb.or(
                        cb.like(normalizedExpr(cb, root.get("name")), pattern),
                        cb.like(normalizedExpr(cb, root.get("username")), pattern)));
            }

            if (predicates.isEmpty()) {
                return cb.conjunction();
            }
            return cb.and(predicates.toArray(Predicate[]::new));
        };
    }

    private static Expression<String> normalizedExpr(
            final CriteriaBuilder cb,
            final Expression<String> field) {
        Expression<String> expr = cb.lower(field);
        for (final String[] replacement : ASCII_REPLACEMENTS) {
            expr = replace(cb, expr, replacement[0], replacement[1]);
        }
        return expr;
    }

    private static Expression<String> replace(
            final CriteriaBuilder cb,
            final Expression<String> expression,
            final String from,
            final String to) {
        return cb.function("replace", String.class, expression, cb.literal(from), cb.literal(to));
    }
}
