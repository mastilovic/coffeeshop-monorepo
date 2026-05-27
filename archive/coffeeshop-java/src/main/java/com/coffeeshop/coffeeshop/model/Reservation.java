package com.coffeeshop.coffeeshop.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;

import java.util.UUID;

@Entity
@jakarta.persistence.Table(
        name = "reservations",
        uniqueConstraints = @UniqueConstraint(columnNames = {"user_id", "event_id"}))
public class Reservation {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;
    @JsonIgnoreProperties(value = {"reservations", "reviews", "shops"})
    @ManyToOne
    @JoinColumn(name = "user_id")
    private User user;
    @JsonIgnoreProperties(value = {"users", "reviews", "tables", "events"})
    @ManyToOne
    @JoinColumn(name = "shop_id", nullable = true)
    private Shop shop;
    @Column(nullable = false)
    private int partySize;
    @OneToOne
    @JoinColumn(name = "reservation_request_id", unique = true, nullable = true)
    @JsonIgnoreProperties(value = {"reservation"})
    private ReservationRequest reservationRequest;
    @JsonIgnoreProperties(value = {"reservations", "shop"})
    @ManyToOne
    @JoinColumn(name = "table_id", nullable = true)
    private Table table;
    @JsonIgnoreProperties(value = {"shop"})
    @ManyToOne
    @JoinColumn(name = "event_id", nullable = true)
    private Event event;

    public Reservation() {
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

    public int getPartySize() {
        return partySize;
    }

    public void setPartySize(int partySize) {
        this.partySize = partySize;
    }

    public ReservationRequest getReservationRequest() {
        return reservationRequest;
    }

    public void setReservationRequest(ReservationRequest reservationRequest) {
        this.reservationRequest = reservationRequest;
    }

    public Table getTable() {
        return table;
    }

    public void setTable(Table table) {
        this.table = table;
    }

    public Event getEvent() {
        return event;
    }

    public void setEvent(Event event) {
        this.event = event;
    }
}
