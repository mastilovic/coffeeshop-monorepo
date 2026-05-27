package com.coffeeshop.coffeeshop.service.impl;

import com.coffeeshop.coffeeshop.auth.CurrentUserService;
import com.coffeeshop.coffeeshop.exception.ResourceNotFoundException;
import com.coffeeshop.coffeeshop.model.*;
import com.coffeeshop.coffeeshop.model.enums.ReservationStatus;
import com.coffeeshop.coffeeshop.model.enums.UserShopRelationshipType;
import com.coffeeshop.coffeeshop.model.enums.UserType;
import com.coffeeshop.coffeeshop.repository.*;
import com.coffeeshop.coffeeshop.service.EventTableAvailabilityService;
import com.coffeeshop.coffeeshop.service.ReservationRequestService;
import com.coffeeshop.coffeeshop.service.UserShopService;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.*;

@Service
@Transactional
public class ReservationRequestServiceImpl implements ReservationRequestService {

    private final ReservationRequestRepository reservationRequestRepository;
    private final ReservationRepository reservationRepository;
    private final UserRepository userRepository;
    private final ShopRepository shopRepository;
    private final TableRepository tableRepository;
    private final EventRepository eventRepository;
    private final EventTableAvailabilityService eventTableAvailabilityService;
    private final CurrentUserService currentUserService;
    private final UserShopService userShopService;
    private final UserShopRepository userShopRepository;

    public ReservationRequestServiceImpl(
            final ReservationRequestRepository reservationRequestRepository,
            final ReservationRepository reservationRepository,
            final UserRepository userRepository,
            final ShopRepository shopRepository,
            final TableRepository tableRepository,
            final EventRepository eventRepository,
            final EventTableAvailabilityService eventTableAvailabilityService,
            final CurrentUserService currentUserService,
            final UserShopService userShopService,
            final UserShopRepository userShopRepository) {
        this.reservationRequestRepository = reservationRequestRepository;
        this.reservationRepository = reservationRepository;
        this.userRepository = userRepository;
        this.shopRepository = shopRepository;
        this.tableRepository = tableRepository;
        this.eventRepository = eventRepository;
        this.eventTableAvailabilityService = eventTableAvailabilityService;
        this.currentUserService = currentUserService;
        this.userShopService = userShopService;
        this.userShopRepository = userShopRepository;
    }

    @Override
    public List<ReservationRequest> findForCurrentUser(final Optional<UUID> shopId) {
        final User currentUser = currentUserService.requireCurrentUser();
        if (isAdmin(currentUser)) {
            if (shopId.isPresent()) {
                return reservationRequestRepository.findByShopId(shopId.get());
            }
            return reservationRequestRepository.findAll();
        }
        if (currentUser.getUserType() == UserType.SHOP_OWNER
                || userShopService.ownsAnyShop(currentUser.getId())) {
            if (shopId.isPresent()) {
                assertShopOwnedBy(shopId.get(), currentUser);
                return reservationRequestRepository.findByShopId(shopId.get());
            }
            return mergeManagedAndPersonalRequests(
                    currentUser.getId(),
                    reservationRequestRepository.findByUserId(currentUser.getId()));
        }
        if (shopId.isPresent()) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Customers cannot list reservation requests by shop");
        }
        return reservationRequestRepository.findByUserId(currentUser.getId());
    }

    @Override
    public ReservationRequest createRequest(
            final UUID userId,
            final UUID shopId,
            final String eventId,
            final int partySize) {
        if (userId == null) {
            throw new IllegalArgumentException("User ID is required");
        }
        if (shopId == null) {
            throw new IllegalArgumentException("Shop ID is required");
        }
        if (eventId == null || eventId.isBlank()) {
            throw new IllegalArgumentException("Event ID is required");
        }
        if (partySize < 1) {
            throw new IllegalArgumentException("partySize must be at least 1");
        }
        final User currentUser = currentUserService.requireCurrentUser();
        final User user = userRepository.findById(userId)
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + userId));
        final Shop shop = shopRepository.findById(shopId)
                .orElseThrow(() -> new ResourceNotFoundException("Shop not found with id: " + shopId));
        assertCanCreateRequest(currentUser, userId, shop);
        final Event event = eventRepository.findById(eventId)
                .orElseThrow(() -> new ResourceNotFoundException("Event not found with id: " + eventId));
        if (event.getShop() == null || !event.getShop().getId().equals(shopId)) {
            throw new IllegalArgumentException("Event must belong to the selected shop");
        }
        assertNoActiveEventBooking(userId, eventId);
        final ReservationRequest request = new ReservationRequest();
        request.setUser(user);
        request.setShop(shop);
        request.setEvent(event);
        request.setPartySize(partySize);
        request.setStatus(ReservationStatus.PENDING);
        return reservationRequestRepository.save(request);
    }

    @Override
    public ReservationRequest accept(final UUID reservationRequestId, final UUID tableId) {
        if (reservationRequestId == null) {
            throw new IllegalArgumentException("Reservation request ID cannot be null");
        }
        if (tableId == null) {
            throw new IllegalArgumentException("Table ID cannot be null");
        }
        final ReservationRequest request = reservationRequestRepository.findById(reservationRequestId)
                .orElseThrow(() -> new ResourceNotFoundException("Reservation request not found with id: " + reservationRequestId));
        assertCanManageRequest(request);
        if (request.getStatus() != ReservationStatus.PENDING) {
            throw new IllegalArgumentException("Only pending reservation requests can be accepted");
        }
        if (request.getShop() == null) {
            throw new IllegalArgumentException("Reservation request has no shop");
        }
        final Table table = tableRepository.findById(tableId)
                .orElseThrow(() -> new ResourceNotFoundException("Table not found with id: " + tableId));
        if (table.getShop() == null) {
            throw new IllegalArgumentException("Table must belong to a shop");
        }
        if (!table.getShop().getId().equals(request.getShop().getId())) {
            throw new IllegalArgumentException("Table must belong to the same shop as the reservation request");
        }
        if (table.getCapacity() < request.getPartySize()) {
            throw new IllegalArgumentException("Table capacity is less than partySize");
        }
        eventTableAvailabilityService.assertHasFreeTable(request.getEvent());
        assertNoConflictingEventBookingOnAccept(request);
        final Reservation reservation = new Reservation();
        reservation.setUser(request.getUser());
        reservation.setShop(request.getShop());
        reservation.setTable(table);
        reservation.setPartySize(request.getPartySize());
        reservation.setEvent(request.getEvent());
        reservation.setReservationRequest(request);
        final Reservation saved = reservationRepository.save(reservation);
        request.setStatus(ReservationStatus.ACCEPTED);
        request.setReservation(saved);
        return reservationRequestRepository.save(request);
    }

    @Override
    public ReservationRequest deny(final UUID reservationRequestId) {
        if (reservationRequestId == null) {
            throw new IllegalArgumentException("Reservation request ID cannot be null");
        }
        final ReservationRequest request = reservationRequestRepository.findById(reservationRequestId)
                .orElseThrow(() -> new ResourceNotFoundException("Reservation request not found with id: " + reservationRequestId));
        assertCanManageRequest(request);
        if (request.getStatus() != ReservationStatus.PENDING) {
            throw new IllegalArgumentException("Only pending reservation requests can be denied");
        }
        request.setStatus(ReservationStatus.DENIED);
        return reservationRequestRepository.save(request);
    }

    private void assertCanCreateRequest(final User currentUser, final UUID userId, final Shop shop) {
        if (isAdmin(currentUser)) {
            return;
        }
        final boolean isOwner = currentUser.getUserType() == UserType.SHOP_OWNER
                || userShopService.ownsAnyShop(currentUser.getId());
        if (isOwner) {
            if (userShopService.isOwner(currentUser, shop)) {
                return;
            }
            if (currentUser.getId().equals(userId)) {
                return;
            }
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You do not own this shop");
        }
        if (!currentUser.getId().equals(userId)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Customers can only create reservation requests for themselves");
        }
    }

    private void assertCanManageRequest(final ReservationRequest request) {
        if (request.getShop() == null) {
            throw new IllegalArgumentException("Reservation request has no shop");
        }
        final User currentUser = currentUserService.requireCurrentUser();
        if (isAdmin(currentUser)) {
            return;
        }
        if (!userShopService.isOwner(currentUser, request.getShop())) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the shop owner can manage reservation requests");
        }
    }

    private List<ReservationRequest> mergeManagedAndPersonalRequests(
            final UUID ownerId,
            final List<ReservationRequest> personalRequests) {
        final List<ReservationRequest> managedRequests = userShopRepository.findReservationRequestsByOwnerId(
                ownerId, UserShopRelationshipType.OWNER);
        final Map<UUID, ReservationRequest> merged = new LinkedHashMap<>();
        for (final ReservationRequest request : managedRequests) {
            merged.put(request.getId(), request);
        }
        for (final ReservationRequest request : personalRequests) {
            merged.put(request.getId(), request);
        }
        return new ArrayList<>(merged.values());
    }

    private void assertShopOwnedBy(final UUID shopId, final User currentUser) {
        final Shop shop = shopRepository.findById(shopId)
                .orElseThrow(() -> new ResourceNotFoundException("Shop not found with id: " + shopId));
        if (!userShopService.isOwner(currentUser, shop)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "You do not own this shop");
        }
    }

    private boolean isAdmin(final User user) {
        if (user.getUserType() == UserType.ADMIN) {
            return true;
        }
        return SecurityContextHolder.getContext().getAuthentication().getAuthorities().stream()
                .map(GrantedAuthority::getAuthority)
                .anyMatch("ROLE_ADMIN"::equals);
    }

    private void assertNoActiveEventBooking(final UUID userId, final String eventId) {
        if (hasActiveEventBooking(userId, eventId, null)) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "This user already has a reservation request or reservation for this event");
        }
    }

    private void assertNoConflictingEventBookingOnAccept(final ReservationRequest request) {
        if (request.getUser() == null || request.getEvent() == null) {
            throw new IllegalArgumentException("Reservation request must have user and event");
        }
        if (hasActiveEventBooking(
                request.getUser().getId(),
                request.getEvent().getEventId(),
                request.getId())) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "This user already has a reservation request or reservation for this event");
        }
    }

    private boolean hasActiveEventBooking(
            final UUID userId,
            final String eventId,
            final UUID excludeRequestId) {
        final Collection<ReservationStatus> blockingStatuses = List.of(
                ReservationStatus.PENDING, ReservationStatus.ACCEPTED);
        final boolean hasBlockingRequest = excludeRequestId == null
                ? reservationRequestRepository.existsByUser_IdAndEvent_EventIdAndStatusIn(
                userId, eventId, blockingStatuses)
                : reservationRequestRepository.existsByUser_IdAndEvent_EventIdAndStatusInAndIdNot(
                userId, eventId, blockingStatuses, excludeRequestId);
        return hasBlockingRequest
                || reservationRepository.existsByUser_IdAndEvent_EventId(userId, eventId);
    }
}
