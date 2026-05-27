package com.coffeeshop.coffeeshop.model.dto.response;

import com.coffeeshop.coffeeshop.model.enums.UserType;

import java.util.List;
import java.util.UUID;

public class UserProfileResponseDto {
    private UUID id;
    private String name;
    private String username;
    private String email;
    private UserType userType;
    private List<RoleResponseDto> roles;
    private List<ShopSummaryDto> favouriteShops;
    private List<ReviewResponseDto> reviews;
    private List<ReservationResponseDto> reservations;

    public UUID getId() {
        return id;
    }

    public void setId(final UUID id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(final String name) {
        this.name = name;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(final String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(final String email) {
        this.email = email;
    }

    public UserType getUserType() {
        return userType;
    }

    public void setUserType(final UserType userType) {
        this.userType = userType;
    }

    public List<RoleResponseDto> getRoles() {
        return roles;
    }

    public void setRoles(final List<RoleResponseDto> roles) {
        this.roles = roles;
    }

    public List<ShopSummaryDto> getFavouriteShops() {
        return favouriteShops;
    }

    public void setFavouriteShops(final List<ShopSummaryDto> favouriteShops) {
        this.favouriteShops = favouriteShops;
    }

    public List<ReviewResponseDto> getReviews() {
        return reviews;
    }

    public void setReviews(final List<ReviewResponseDto> reviews) {
        this.reviews = reviews;
    }

    public List<ReservationResponseDto> getReservations() {
        return reservations;
    }

    public void setReservations(final List<ReservationResponseDto> reservations) {
        this.reservations = reservations;
    }
}
