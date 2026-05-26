package com.coffeeshop.coffeeshop.repository;

import com.coffeeshop.coffeeshop.model.Shop;
import com.coffeeshop.coffeeshop.model.UserShop;
import com.coffeeshop.coffeeshop.model.enums.UserShopRelationshipType;
import com.coffeeshop.coffeeshop.util.SearchTextNormalizer;
import jakarta.persistence.criteria.CriteriaBuilder;
import jakarta.persistence.criteria.CriteriaQuery;
import jakarta.persistence.criteria.Expression;
import jakarta.persistence.criteria.Predicate;
import jakarta.persistence.criteria.Root;
import jakarta.persistence.criteria.Subquery;
import org.springframework.data.jpa.domain.Specification;

import java.util.ArrayList;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public final class ShopSpecifications {

    private static final String[][] ASCII_REPLACEMENTS = {
            {"đ", "dj"},
            {"č", "c"},
            {"ć", "c"},
            {"š", "s"},
            {"ž", "z"},
    };

    private ShopSpecifications() {
    }

    public static Specification<Shop> search(
            final Optional<String> query,
            final Optional<UUID> favouriteUserId) {
        return (root, criteriaQuery, cb) -> {
            applyOrdering(root, criteriaQuery, cb, favouriteUserId);

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
                        cb.like(normalizedExpr(cb, root.get("city")), pattern),
                        cb.like(normalizedExpr(cb, root.get("address")), pattern)));
            }

            if (predicates.isEmpty()) {
                return cb.conjunction();
            }
            return cb.and(predicates.toArray(Predicate[]::new));
        };
    }

    private static void applyOrdering(
            final Root<Shop> root,
            final CriteriaQuery<?> criteriaQuery,
            final CriteriaBuilder cb,
            final Optional<UUID> favouriteUserId) {
        if (criteriaQuery.getResultType() == Long.class || criteriaQuery.getResultType() == long.class) {
            return;
        }

        if (favouriteUserId.isPresent()) {
            final Subquery<Long> favouriteExists = criteriaQuery.subquery(Long.class);
            final Root<UserShop> userShopRoot = favouriteExists.from(UserShop.class);
            favouriteExists.select(cb.literal(1L));
            favouriteExists.where(
                    cb.equal(userShopRoot.get("shop"), root),
                    cb.equal(userShopRoot.get("user").get("id"), favouriteUserId.get()),
                    cb.equal(userShopRoot.get("relationshipType"), UserShopRelationshipType.FAVOURITE));

            final Expression<Integer> favouriteFirst = cb.<Integer>selectCase()
                    .when(cb.exists(favouriteExists), cb.literal(0))
                    .otherwise(cb.literal(1));
            criteriaQuery.orderBy(cb.asc(favouriteFirst), cb.asc(root.get("name")));
        } else {
            criteriaQuery.orderBy(cb.asc(root.get("name")));
        }
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
