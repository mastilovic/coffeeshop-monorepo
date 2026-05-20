package com.coffeeshop.coffeeshop.model.dto.response;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

public class ReviewResponseDto {
    private UUID id;
    private String title;
    private String description;
    private Integer rating;
    private Instant reviewDate;
    private boolean commentsEnabled;
    private List<ReviewCommentResponseDto> comments = new ArrayList<>();
    private UserSummaryDto user;
    private ShopSummaryDto shop;

    public UUID getId() {
        return id;
    }

    public void setId(final UUID id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(final String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(final String description) {
        this.description = description;
    }

    public Integer getRating() {
        return rating;
    }

    public void setRating(final Integer rating) {
        this.rating = rating;
    }

    public Instant getReviewDate() {
        return reviewDate;
    }

    public void setReviewDate(final Instant reviewDate) {
        this.reviewDate = reviewDate;
    }

    public boolean isCommentsEnabled() {
        return commentsEnabled;
    }

    public void setCommentsEnabled(final boolean commentsEnabled) {
        this.commentsEnabled = commentsEnabled;
    }

    public List<ReviewCommentResponseDto> getComments() {
        return comments;
    }

    public void setComments(final List<ReviewCommentResponseDto> comments) {
        this.comments = comments;
    }

    public UserSummaryDto getUser() {
        return user;
    }

    public void setUser(final UserSummaryDto user) {
        this.user = user;
    }

    public ShopSummaryDto getShop() {
        return shop;
    }

    public void setShop(final ShopSummaryDto shop) {
        this.shop = shop;
    }
}
