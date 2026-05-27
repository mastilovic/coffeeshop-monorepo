package com.coffeeshop.coffeeshop.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;

import java.util.List;
import java.util.UUID;

@Entity
public class Shop {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;
    private String name;
    private String address;
    private String city;
    private String phoneNumber;
    private String email;

    @JsonIgnoreProperties(value = {"user", "shop"})
    @OneToMany(mappedBy = "shop", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<UserShop> userShops;

    @JsonIgnoreProperties(value = {"shop", "items"})
    @ManyToOne(fetch = FetchType.EAGER)
    @JoinColumn(name = "current_menu_id", referencedColumnName = "id", nullable = true)
    private Menu currentMenu;

    @JsonIgnoreProperties(value = {"shop", "items"})
    @OneToMany(mappedBy = "shop", fetch = FetchType.LAZY, cascade = CascadeType.ALL)
    private List<Menu> menus;
    @JsonIgnoreProperties(value = {"shop"})
    @OneToOne(cascade = CascadeType.ALL)
    @JoinColumn(name = "loyalty_plan_id", referencedColumnName = "id", nullable = true)
    private LoyaltyPlan loyaltyPlan;
    @JsonIgnoreProperties(value = {"shop"})
    @OneToMany(mappedBy = "shop", fetch = FetchType.EAGER, cascade = CascadeType.ALL)
    private List<Event> events;
    @OneToMany(mappedBy = "shop", fetch = FetchType.EAGER, cascade = CascadeType.ALL)
    private List<Table> tables;
    @JsonIgnoreProperties(value = {"shop"})
    @OneToMany(mappedBy = "shop", fetch = FetchType.EAGER, cascade = CascadeType.ALL)
    private List<Review> reviews;
    @JsonIgnoreProperties(value = {"shop"})
    @OneToMany(mappedBy = "shop", fetch = FetchType.EAGER, cascade = CascadeType.ALL)
    private List<Contact> contacts;

    @Transient
    private UUID ownerUserIdForCreate;

    @Transient
    private UUID newOwnerUserIdForUpdate;

    public Shop() {
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
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

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public List<UserShop> getUserShops() {
        return userShops;
    }

    public void setUserShops(final List<UserShop> userShops) {
        this.userShops = userShops;
    }

    public UUID getOwnerUserIdForCreate() {
        return ownerUserIdForCreate;
    }

    public void setOwnerUserIdForCreate(final UUID ownerUserIdForCreate) {
        this.ownerUserIdForCreate = ownerUserIdForCreate;
    }

    public UUID getNewOwnerUserIdForUpdate() {
        return newOwnerUserIdForUpdate;
    }

    public void setNewOwnerUserIdForUpdate(final UUID newOwnerUserIdForUpdate) {
        this.newOwnerUserIdForUpdate = newOwnerUserIdForUpdate;
    }

    public Menu getCurrentMenu() {
        return currentMenu;
    }

    public void setCurrentMenu(final Menu currentMenu) {
        this.currentMenu = currentMenu;
    }

    public List<Menu> getMenus() {
        return menus;
    }

    public void setMenus(final List<Menu> menus) {
        this.menus = menus;
    }

    public LoyaltyPlan getLoyaltyPlan() {
        return loyaltyPlan;
    }

    public void setLoyaltyPlan(LoyaltyPlan loyaltyPlan) {
        this.loyaltyPlan = loyaltyPlan;
    }

    public List<Event> getEvents() {
        return events;
    }

    public void setEvents(List<Event> events) {
        this.events = events;
    }

    public List<Table> getTables() {
        return tables;
    }

    public void setTables(List<Table> tables) {
        this.tables = tables;
    }

    public List<Review> getReviews() {
        return reviews;
    }

    public void setReviews(List<Review> reviews) {
        this.reviews = reviews;
    }

    public List<Contact> getContacts() {
        return contacts;
    }

    public void setContacts(List<Contact> contacts) {
        this.contacts = contacts;
    }
}
