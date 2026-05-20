package com.coffeeshop.coffeeshop.service;

import com.coffeeshop.coffeeshop.model.Review;
import com.coffeeshop.coffeeshop.model.dto.request.ReviewUpdateRequest;

import java.util.List;
import java.util.UUID;

public interface ReviewService {

    List<Review> findAll();

    Review getById(UUID id);

    Review create(Review entity);

    Review update(UUID id, Review entity);

    Review update(UUID id, Review entity, ReviewUpdateRequest request);

    void deleteById(UUID id);
}
