package com.coffeeshop.coffeeshop.service;

import com.coffeeshop.coffeeshop.model.Review;
import com.coffeeshop.coffeeshop.model.ReviewComment;
import com.coffeeshop.coffeeshop.repository.ReviewCommentRepository;
import org.springframework.stereotype.Component;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.UUID;
import java.util.stream.Collectors;

@Component
public class ReviewCommentLoader {

    private final ReviewCommentRepository reviewCommentRepository;

    public ReviewCommentLoader(final ReviewCommentRepository reviewCommentRepository) {
        this.reviewCommentRepository = reviewCommentRepository;
    }

    public void loadCommentsForReviews(final List<Review> reviews) {
        if (reviews == null || reviews.isEmpty()) {
            return;
        }
        final List<UUID> reviewIds = reviews.stream()
                .map(Review::getId)
                .filter(id -> id != null)
                .toList();
        if (reviewIds.isEmpty()) {
            return;
        }
        final Map<UUID, List<ReviewComment>> commentsByReviewId = reviewCommentRepository
                .findByReview_IdInOrderByCreatedAtAsc(reviewIds)
                .stream()
                .collect(Collectors.groupingBy(comment -> comment.getReview().getId()));
        for (final Review review : reviews) {
            final List<ReviewComment> loaded = commentsByReviewId.getOrDefault(review.getId(), List.of());
            review.getComments().clear();
            review.getComments().addAll(loaded);
        }
    }
}
