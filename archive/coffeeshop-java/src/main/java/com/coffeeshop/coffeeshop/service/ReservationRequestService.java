package com.coffeeshop.coffeeshop.service;

import com.coffeeshop.coffeeshop.model.ReservationRequest;

import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface ReservationRequestService {

    List<ReservationRequest> findForCurrentUser(Optional<UUID> shopId);

    ReservationRequest createRequest(
            UUID userId,
            UUID shopId,
            String eventId,
            int partySize);

    ReservationRequest accept(UUID reservationRequestId, UUID tableId);

    ReservationRequest deny(UUID reservationRequestId);
}
