package com.coffeeshop.coffeeshop.service;

import com.coffeeshop.coffeeshop.model.Reservation;

import java.util.List;
import java.util.UUID;

public interface ReservationService {

    List<Reservation> findAll();

    Reservation getById(UUID id);

    Reservation create(Reservation entity);

    Reservation update(UUID id, Reservation entity);

    void deleteById(UUID id);
}
