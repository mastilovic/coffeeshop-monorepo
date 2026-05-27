package com.coffeeshop.coffeeshop.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;

import java.util.List;
import java.util.UUID;

@Entity
@jakarta.persistence.Table(name = "tables")
public class Table {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;
    private int number;
    private int capacity;
    @ManyToOne
    @JoinColumn(name = "shop_id")
    private Shop shop;
    @JsonIgnoreProperties(value = {"table"})
    @OneToMany(mappedBy = "table", fetch = FetchType.EAGER, cascade = CascadeType.ALL)
    private List<Reservation> reservations;

    public Table() {
    }

    public Table(UUID id, int number, int capacity, Shop shop) {
        this.id = id;
        this.number = number;
        this.capacity = capacity;
        this.shop = shop;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public int getNumber() {
        return number;
    }

    public void setNumber(int number) {
        this.number = number;
    }

    public int getCapacity() {
        return capacity;
    }

    public void setCapacity(int capacity) {
        this.capacity = capacity;
    }

    public Shop getShop() {
        return shop;
    }

    public void setShop(Shop shop) {
        this.shop = shop;
    }

    public List<Reservation> getReservations() {
        return reservations;
    }

    public void setReservations(List<Reservation> reservations) {
        this.reservations = reservations;
    }
}
