package com.coffeeshop.coffeeshop.repository;

import com.coffeeshop.coffeeshop.model.Event;
import com.coffeeshop.coffeeshop.model.Shop;
import com.coffeeshop.coffeeshop.util.SearchTextNormalizer;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.Expression;
import jakarta.persistence.criteria.Join;
import jakarta.persistence.criteria.JoinType;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.jpa.domain.Specification;

import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.ArrayList;
import java.util.List;
import java.util.Optional;

public final class EventSpecifications {

    private static final DateTimeFormatter ISO_DATE = DateTimeFormatter.ISO_LOCAL_DATE;

    private static final String[][] ASCII_REPLACEMENTS = {
            {"đ", "dj"},
            {"č", "c"},
            {"ć", "c"},
            {"š", "s"},
            {"ž", "z"},
    };

    private EventSpecifications() {
    }

    public static Specification<Event> search(
            final Optional<String> query,
            final Optional<LocalDate> dateFrom,
            final Optional<LocalDate> dateTo) {
        return (root, criteriaQuery, cb) -> {
            if (criteriaQuery.getResultType() != Long.class && criteriaQuery.getResultType() != long.class) {
                root.fetch("shop", JoinType.LEFT);
                criteriaQuery.distinct(true);
            }

            final List<Predicate> predicates = new ArrayList<>();

            final String normalized = query
                    .map(String::trim)
                    .filter(s -> !s.isEmpty())
                    .map(SearchTextNormalizer::normalizeForSearch)
                    .orElse(null);

            if (normalized != null) {
                final Join<Event, Shop> shop = root.join("shop", JoinType.LEFT);
                final String pattern = "%" + normalized + "%";
                predicates.add(cb.or(
                        cb.like(normalizedExpr(cb, root.get("eventName")), pattern),
                        cb.like(normalizedExpr(cb, root.get("description")), pattern),
                        cb.like(normalizedExpr(cb, shop.get("name")), pattern),
                        cb.like(normalizedExpr(cb, shop.get("city")), pattern)));
            }

            dateFrom.ifPresent(from -> predicates.add(
                    cb.greaterThanOrEqualTo(root.get("eventDate"), from.format(ISO_DATE))));

            dateTo.ifPresent(to -> predicates.add(
                    cb.lessThan(root.get("eventDate"), to.plusDays(1).format(ISO_DATE))));

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
