package com.coffeeshop.coffeeshop.service;

import com.coffeeshop.coffeeshop.model.ReviewComment;

import java.util.List;
import java.util.UUID;

public interface ReviewCommentService {

    List<ReviewComment> findByReviewId(UUID reviewId);

    ReviewComment create(UUID reviewId, String body);
}
