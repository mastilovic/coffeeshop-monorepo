package com.coffeeshop.coffeeshop.model;

import com.coffeeshop.coffeeshop.model.enums.ReservationStatus;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;

import java.util.UUID;

@Entity
@jakarta.persistence.Table(name = "reservation_request")
public class ReservationRequest {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;
    @JsonIgnoreProperties(value = {"reservations", "reviews", "shops"})
    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;
    @JsonIgnoreProperties(value = {"users", "reviews", "tables", "events"})
    @ManyToOne
    @JoinColumn(name = "shop_id")
    private Shop shop;
    @JsonIgnoreProperties(value = {"shop"})
    @ManyToOne
    @JoinColumn(name = "event_id", nullable = false)
    private Event event;
    @Column(nullable = false)
    private int partySize;
    @Enumerated(EnumType.STRING)
    @Column(nullable = false)
    private ReservationStatus status;
    @OneToOne(mappedBy = "reservationRequest")
    @JsonIgnoreProperties(value = {"reservationRequest", "user", "shop", "table"})
    private Reservation reservation;

    public ReservationRequest() {
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
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

    public Event getEvent() {
        return event;
    }

    public void setEvent(Event event) {
        this.event = event;
    }

    public int getPartySize() {
        return partySize;
    }

    public void setPartySize(int partySize) {
        this.partySize = partySize;
    }

    public ReservationStatus getStatus() {
        return status;
    }

    public void setStatus(ReservationStatus status) {
        this.status = status;
    }

    public Reservation getReservation() {
        return reservation;
    }

    public void setReservation(Reservation reservation) {
        this.reservation = reservation;
    }
}
