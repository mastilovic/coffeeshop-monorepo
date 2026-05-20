package com.coffeeshop.coffeeshop.util;

import com.coffeeshop.coffeeshop.model.Review;
import org.junit.jupiter.api.Test;

import java.util.List;

import static org.assertj.core.api.Assertions.assertThat;

class RatingAggregationUtilsTest {

    @Test
    void fromReviews_emptyList_returnsZeroCountAndNullAverage() {
        final RatingAggregationUtils.RatingSummary summary = RatingAggregationUtils.fromReviews(List.of());
        assertThat(summary.reviewCount()).isZero();
        assertThat(summary.averageRating()).isNull();
    }

    @Test
    void fromReviews_nullList_returnsZeroCountAndNullAverage() {
        final RatingAggregationUtils.RatingSummary summary = RatingAggregationUtils.fromReviews(null);
        assertThat(summary.reviewCount()).isZero();
        assertThat(summary.averageRating()).isNull();
    }

    @Test
    void fromReviews_singleRating_returnsAverage() {
        final Review review = new Review();
        review.setRating(5);

        final RatingAggregationUtils.RatingSummary summary = RatingAggregationUtils.fromReviews(List.of(review));
        assertThat(summary.reviewCount()).isEqualTo(1);
        assertThat(summary.averageRating()).isEqualTo(5.0);
    }

    @Test
    void fromReviews_multipleRatings_roundsToOneDecimal() {
        final Review first = new Review();
        first.setRating(5);
        final Review second = new Review();
        second.setRating(3);

        final RatingAggregationUtils.RatingSummary summary =
                RatingAggregationUtils.fromReviews(List.of(first, second));
        assertThat(summary.reviewCount()).isEqualTo(2);
        assertThat(summary.averageRating()).isEqualTo(4.0);
    }

    @Test
    void fromReviews_skipsNullRatings() {
        final Review withRating = new Review();
        withRating.setRating(4);
        final Review withoutRating = new Review();

        final RatingAggregationUtils.RatingSummary summary =
                RatingAggregationUtils.fromReviews(List.of(withRating, withoutRating));
        assertThat(summary.reviewCount()).isEqualTo(1);
        assertThat(summary.averageRating()).isEqualTo(4.0);
    }
}
