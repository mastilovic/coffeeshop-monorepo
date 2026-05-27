package com.coffeeshop.coffeeshop.repository;

import com.coffeeshop.coffeeshop.model.ReservationRequest;
import com.coffeeshop.coffeeshop.model.enums.ReservationStatus;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Collection;
import java.util.List;
import java.util.UUID;

public interface ReservationRequestRepository extends JpaRepository<ReservationRequest, UUID> {

    List<ReservationRequest> findByUserId(UUID userId);

    List<ReservationRequest> findByShopId(UUID shopId);

    boolean existsByUser_IdAndEvent_EventIdAndStatusIn(
            UUID userId, String eventId, Collection<ReservationStatus> statuses);

    boolean existsByUser_IdAndEvent_EventIdAndStatusInAndIdNot(
            UUID userId, String eventId, Collection<ReservationStatus> statuses, UUID excludeId);
}
