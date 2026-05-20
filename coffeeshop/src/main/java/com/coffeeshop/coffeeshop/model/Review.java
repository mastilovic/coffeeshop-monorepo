package com.coffeeshop.coffeeshop.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;

import java.time.Instant;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Entity
public class Review {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;
    private String title;
    private String description;
    private Integer rating;
    private Instant reviewDate;
    private boolean commentsEnabled = true;
    @OneToMany(mappedBy = "review")
    @JsonIgnoreProperties("review")
    private List<ReviewComment> comments = new ArrayList<>();
    @JsonIgnoreProperties(value = {"reviews", "shops", "reservations"})
    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;
    @JsonIgnoreProperties(value = {"users", "reviews", "tables", "events"})
    @ManyToOne
    @JoinColumn(name = "shop_id")
    private Shop shop;

    public Review() {
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public Integer getRating() {
        return rating;
    }

    public void setRating(Integer rating) {
        this.rating = rating;
    }

    public Instant getReviewDate() {
        return reviewDate;
    }

    public void setReviewDate(Instant reviewDate) {
        this.reviewDate = reviewDate;
    }

    public boolean isCommentsEnabled() {
        return commentsEnabled;
    }

    public void setCommentsEnabled(final boolean commentsEnabled) {
        this.commentsEnabled = commentsEnabled;
    }

    public List<ReviewComment> getComments() {
        return comments;
    }

    public void setComments(final List<ReviewComment> comments) {
        this.comments = comments;
    }

    public User getUser() {
        return user;
    }

    public void setUser(User user) {
        this.user = user;
    }

    public Shop getShop() {
        return shop;
    }

    public void setShop(Shop shop) {
        this.shop = shop;
    }
}
