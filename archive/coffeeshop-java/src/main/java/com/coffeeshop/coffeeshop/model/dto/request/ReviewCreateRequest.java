package com.coffeeshop.coffeeshop.model.dto.request;

import jakarta.validation.constraints.Max;
import jakarta.validation.constraints.Min;
import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.NotNull;

import java.util.UUID;

public class ReviewCreateRequest {
    private String title;

    @NotBlank
    private String description;

    @NotNull
    @Min(1)
    @Max(5)
    private Integer rating;

    @NotNull
    private UUID shopId;

    private Boolean commentsEnabled;

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

    public UUID getShopId() {
        return shopId;
    }

    public void setShopId(final UUID shopId) {
        this.shopId = shopId;
    }

    public Boolean getCommentsEnabled() {
        return commentsEnabled;
    }

    public void setCommentsEnabled(final Boolean commentsEnabled) {
        this.commentsEnabled = commentsEnabled;
    }
}
