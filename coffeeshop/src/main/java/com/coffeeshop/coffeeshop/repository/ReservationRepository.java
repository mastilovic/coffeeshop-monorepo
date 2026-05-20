package com.coffeeshop.coffeeshop.repository;

import com.coffeeshop.coffeeshop.model.Reservation;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface ReservationRepository extends JpaRepository<Reservation, UUID> {

    boolean existsByUser_IdAndEvent_EventId(UUID userId, String eventId);

    long countByEvent_EventId(String eventId);
}
