package com.coffeeshop.coffeeshop.mapper;

import com.coffeeshop.coffeeshop.model.Review;
import com.coffeeshop.coffeeshop.model.ReviewComment;
import com.coffeeshop.coffeeshop.model.Shop;
import com.coffeeshop.coffeeshop.model.dto.request.ReviewCreateRequest;
import com.coffeeshop.coffeeshop.model.dto.request.ReviewUpdateRequest;
import com.coffeeshop.coffeeshop.model.dto.response.ReviewResponseDto;
import java.util.List;

import org.springframework.stereotype.Service;

@Service
public class ReviewMapper {

    private final UserMapper userMapper;
    private final ShopMapper shopMapper;
    private final ReviewCommentMapper reviewCommentMapper;

    public ReviewMapper(
            final UserMapper userMapper,
            final ShopMapper shopMapper,
            final ReviewCommentMapper reviewCommentMapper) {
        this.userMapper = userMapper;
        this.shopMapper = shopMapper;
        this.reviewCommentMapper = reviewCommentMapper;
    }

    public ReviewResponseDto toReviewResponse(final Review review) {
        if (review == null) {
            return null;
        }
        final ReviewResponseDto dto = new ReviewResponseDto();
        dto.setId(review.getId());
        dto.setTitle(review.getTitle());
        dto.setDescription(review.getDescription());
        dto.setRating(review.getRating());
        dto.setReviewDate(review.getReviewDate());
        dto.setCommentsEnabled(review.isCommentsEnabled());
        final List<ReviewComment> comments = review.getComments() != null ? review.getComments() : List.of();
        dto.setComments(MappingUtils.mapList(comments, reviewCommentMapper::toReviewCommentResponse));
        dto.setUser(userMapper.toUserSummary(review.getUser()));
        dto.setShop(shopMapper.toShopSummary(review.getShop()));
        return dto;
    }

    public Review toReview(final ReviewCreateRequest request) {
        final Review review = new Review();
        review.setTitle(request.getTitle());
        review.setDescription(request.getDescription());
        review.setRating(request.getRating());
        if (request.getCommentsEnabled() != null) {
            review.setCommentsEnabled(request.getCommentsEnabled());
        }
        if (request.getShopId() != null) {
            final Shop shop = new Shop();
            shop.setId(request.getShopId());
            review.setShop(shop);
        }
        return review;
    }

    public Review toReview(final ReviewUpdateRequest request) {
        final Review review = new Review();
        review.setTitle(request.getTitle());
        review.setDescription(request.getDescription());
        review.setRating(request.getRating());
        if (request.getCommentsEnabled() != null) {
            review.setCommentsEnabled(request.getCommentsEnabled());
        }
        return review;
    }
}
