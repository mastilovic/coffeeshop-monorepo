package com.coffeeshop.coffeeshop.util;

import com.coffeeshop.coffeeshop.model.Review;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.List;

public final class RatingAggregationUtils {

    private RatingAggregationUtils() {
    }

    public record RatingSummary(int reviewCount, Double averageRating) {
    }

    public static RatingSummary fromReviews(final List<Review> reviews) {
        if (reviews == null || reviews.isEmpty()) {
            return new RatingSummary(0, null);
        }

        int count = 0;
        int sum = 0;
        for (final Review review : reviews) {
            final Integer rating = review.getRating();
            if (rating == null) {
                continue;
            }
            count++;
            sum += rating;
        }

        if (count == 0) {
            return new RatingSummary(0, null);
        }

        final BigDecimal average = BigDecimal.valueOf(sum)
                .divide(BigDecimal.valueOf(count), 1, RoundingMode.HALF_UP);
        return new RatingSummary(count, average.doubleValue());
    }
}
