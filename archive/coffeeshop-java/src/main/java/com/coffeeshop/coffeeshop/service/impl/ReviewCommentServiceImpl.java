package com.coffeeshop.coffeeshop.service.impl;

import com.coffeeshop.coffeeshop.auth.CurrentUserService;
import com.coffeeshop.coffeeshop.exception.ResourceNotFoundException;
import com.coffeeshop.coffeeshop.model.Review;
import com.coffeeshop.coffeeshop.model.ReviewComment;
import com.coffeeshop.coffeeshop.model.User;
import com.coffeeshop.coffeeshop.repository.ReviewCommentRepository;
import com.coffeeshop.coffeeshop.repository.ReviewRepository;
import com.coffeeshop.coffeeshop.service.ReviewCommentService;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.time.Instant;
import java.util.List;
import java.util.UUID;

@Service
@Transactional
public class ReviewCommentServiceImpl implements ReviewCommentService {

    private final ReviewCommentRepository reviewCommentRepository;
    private final ReviewRepository reviewRepository;
    private final CurrentUserService currentUserService;

    public ReviewCommentServiceImpl(
            final ReviewCommentRepository reviewCommentRepository,
            final ReviewRepository reviewRepository,
            final CurrentUserService currentUserService) {
        this.reviewCommentRepository = reviewCommentRepository;
        this.reviewRepository = reviewRepository;
        this.currentUserService = currentUserService;
    }

    @Override
    public List<ReviewComment> findByReviewId(final UUID reviewId) {
        assertReviewExists(reviewId);
        return reviewCommentRepository.findByReview_IdOrderByCreatedAtAsc(reviewId);
    }

    @Override
    public ReviewComment create(final UUID reviewId, final String body) {
        final Review review = reviewRepository.findById(reviewId)
                .orElseThrow(() -> new ResourceNotFoundException("Review not found with id: " + reviewId));
        if (!review.isCommentsEnabled()) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Comments are disabled for this review");
        }

        final User currentUser = currentUserService.requireCurrentUser();
        final ReviewComment comment = new ReviewComment();
        comment.setBody(body);
        comment.setCreatedAt(Instant.now());
        comment.setUser(currentUser);
        comment.setReview(review);
        return reviewCommentRepository.save(comment);
    }

    private void assertReviewExists(final UUID reviewId) {
        if (reviewId == null) {
            throw new IllegalArgumentException("Review ID cannot be null");
        }
        if (!reviewRepository.existsById(reviewId)) {
            throw new ResourceNotFoundException("Review not found with id: " + reviewId);
        }
    }
}
