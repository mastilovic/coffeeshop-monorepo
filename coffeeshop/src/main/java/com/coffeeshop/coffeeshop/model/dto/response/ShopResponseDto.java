package com.coffeeshop.coffeeshop.model.dto.response;

import java.util.List;
import java.util.UUID;

public class ShopResponseDto {
    private UUID id;
    private String name;
    private String address;
    private String city;
    private String phoneNumber;
    private String email;
    private UserSummaryDto createdBy;
    private List<UserSummaryDto> users;
    private MenuResponseDto currentMenu;
    private List<MenuResponseDto> menuHistory;
    private LoyaltyPlanResponseDto loyaltyPlan;
    private List<EventResponseDto> events;
    private List<TableResponseDto> tables;
    private List<ReviewResponseDto> reviews;
    private Integer reviewCount;
    private Double averageRating;
    private List<ContactResponseDto> contacts;

    private Boolean favouriteByCurrentUser;
    private Long memberCount;

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

    public String getAddress() {
        return address;
    }

    public void setAddress(final String address) {
        this.address = address;
    }

    public String getCity() {
        return city;
    }

    public void setCity(final String city) {
        this.city = city;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(final String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(final String email) {
        this.email = email;
    }

    public UserSummaryDto getCreatedBy() {
        return createdBy;
    }

    public void setCreatedBy(final UserSummaryDto createdBy) {
        this.createdBy = createdBy;
    }

    public List<UserSummaryDto> getUsers() {
        return users;
    }

    public void setUsers(final List<UserSummaryDto> users) {
        this.users = users;
    }

    public MenuResponseDto getCurrentMenu() {
        return currentMenu;
    }

    public void setCurrentMenu(final MenuResponseDto currentMenu) {
        this.currentMenu = currentMenu;
    }

    public List<MenuResponseDto> getMenuHistory() {
        return menuHistory;
    }

    public void setMenuHistory(final List<MenuResponseDto> menuHistory) {
        this.menuHistory = menuHistory;
    }

    public LoyaltyPlanResponseDto getLoyaltyPlan() {
        return loyaltyPlan;
    }

    public void setLoyaltyPlan(final LoyaltyPlanResponseDto loyaltyPlan) {
        this.loyaltyPlan = loyaltyPlan;
    }

    public List<EventResponseDto> getEvents() {
        return events;
    }

    public void setEvents(final List<EventResponseDto> events) {
        this.events = events;
    }

    public List<TableResponseDto> getTables() {
        return tables;
    }

    public void setTables(final List<TableResponseDto> tables) {
        this.tables = tables;
    }

    public List<ReviewResponseDto> getReviews() {
        return reviews;
    }

    public void setReviews(final List<ReviewResponseDto> reviews) {
        this.reviews = reviews;
    }

    public Integer getReviewCount() {
        return reviewCount;
    }

    public void setReviewCount(final Integer reviewCount) {
        this.reviewCount = reviewCount;
    }

    public Double getAverageRating() {
        return averageRating;
    }

    public void setAverageRating(final Double averageRating) {
        this.averageRating = averageRating;
    }

    public List<ContactResponseDto> getContacts() {
        return contacts;
    }

    public void setContacts(final List<ContactResponseDto> contacts) {
        this.contacts = contacts;
    }

    public Boolean getFavouriteByCurrentUser() {
        return favouriteByCurrentUser;
    }

    public void setFavouriteByCurrentUser(final Boolean favouriteByCurrentUser) {
        this.favouriteByCurrentUser = favouriteByCurrentUser;
    }

    public Long getMemberCount() {
        return memberCount;
    }

    public void setMemberCount(final Long memberCount) {
        this.memberCount = memberCount;
    }
}
