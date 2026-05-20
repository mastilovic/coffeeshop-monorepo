package com.coffeeshop.coffeeshop.model;

import com.coffeeshop.coffeeshop.model.enums.UserType;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;

import java.util.List;
import java.util.UUID;

@Entity
@jakarta.persistence.Table(name = "users")
public class User {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;
    private String name;
    @Column(unique = true)
    private String username;
    private String email;
    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    private String password;
    private UserType userType;
    @ManyToMany(cascade = {CascadeType.DETACH, CascadeType.MERGE, CascadeType.PERSIST, CascadeType.REFRESH})
    @JoinTable(
            name = "user_role",
            joinColumns = @JoinColumn(name = "user_id"),
            inverseJoinColumns = @JoinColumn(name = "role_id")
    )
    private List<Role> role;

    @JsonIgnoreProperties(value = {"user", "shop"})
    @OneToMany(mappedBy = "user", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<UserShop> userShops;

    @OneToMany(mappedBy = "user", fetch = FetchType.EAGER, cascade = CascadeType.ALL)
    private List<Review> reviews;
    @JsonIgnoreProperties(value = {"user"})
    @OneToMany(mappedBy = "user", fetch = FetchType.EAGER, cascade = CascadeType.ALL)
    private List<Reservation> reservations;
    @Column(name = "keycloak_subject", unique = true)
    private String keycloakSubject;

    @Transient
    private List<UUID> favouriteShopIdsForUpdate;

    public User() {
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

    public String getUsername() {
        return username;
    }

    public void setUsername(final String username) {
        this.username = username;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPassword() {
        return password;
    }

    public void setPassword(String password) {
        this.password = password;
    }

    public UserType getUserType() {
        return userType;
    }

    public void setUserType(UserType userType) {
        this.userType = userType;
    }

    public List<Role> getRole() {
        return role;
    }

    public void setRole(List<Role> role) {
        this.role = role;
    }

    public List<UserShop> getUserShops() {
        return userShops;
    }

    public void setUserShops(final List<UserShop> userShops) {
        this.userShops = userShops;
    }

    public List<Review> getReviews() {
        return reviews;
    }

    public void setReviews(List<Review> reviews) {
        this.reviews = reviews;
    }

    public List<Reservation> getReservations() {
        return reservations;
    }

    public void setReservations(List<Reservation> reservations) {
        this.reservations = reservations;
    }

    public String getKeycloakSubject() {
        return keycloakSubject;
    }

    public void setKeycloakSubject(final String keycloakSubject) {
        this.keycloakSubject = keycloakSubject;
    }

    public List<UUID> getFavouriteShopIdsForUpdate() {
        return favouriteShopIdsForUpdate;
    }

    public void setFavouriteShopIdsForUpdate(final List<UUID> favouriteShopIdsForUpdate) {
        this.favouriteShopIdsForUpdate = favouriteShopIdsForUpdate;
    }
}
