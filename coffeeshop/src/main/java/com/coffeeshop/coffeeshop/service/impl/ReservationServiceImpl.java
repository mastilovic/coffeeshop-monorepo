package com.coffeeshop.coffeeshop.service.impl;

import com.coffeeshop.coffeeshop.auth.CurrentUserService;
import com.coffeeshop.coffeeshop.exception.ResourceNotFoundException;
import com.coffeeshop.coffeeshop.model.Event;
import com.coffeeshop.coffeeshop.model.Reservation;
import com.coffeeshop.coffeeshop.model.Shop;
import com.coffeeshop.coffeeshop.model.Table;
import com.coffeeshop.coffeeshop.model.User;
import com.coffeeshop.coffeeshop.model.enums.ReservationStatus;
import com.coffeeshop.coffeeshop.model.enums.UserType;
import com.coffeeshop.coffeeshop.repository.EventRepository;
import com.coffeeshop.coffeeshop.repository.ReservationRepository;
import com.coffeeshop.coffeeshop.repository.ReservationRequestRepository;
import com.coffeeshop.coffeeshop.repository.TableRepository;
import com.coffeeshop.coffeeshop.repository.UserRepository;
import com.coffeeshop.coffeeshop.service.EventTableAvailabilityService;
import com.coffeeshop.coffeeshop.service.ReservationService;
import com.coffeeshop.coffeeshop.service.UserShopService;
import org.springframework.http.HttpStatus;
import org.springframework.security.core.GrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.web.server.ResponseStatusException;

import java.util.List;
import java.util.UUID;

@Service
@Transactional
public class ReservationServiceImpl implements ReservationService {

    private final ReservationRepository reservationRepository;
    private final ReservationRequestRepository reservationRequestRepository;
    private final UserRepository userRepository;
    private final TableRepository tableRepository;
    private final EventRepository eventRepository;
    private final EventTableAvailabilityService eventTableAvailabilityService;
    private final CurrentUserService currentUserService;
    private final UserShopService userShopService;

    public ReservationServiceImpl(
            final ReservationRepository reservationRepository,
            final ReservationRequestRepository reservationRequestRepository,
            final UserRepository userRepository,
            final TableRepository tableRepository,
            final EventRepository eventRepository,
            final EventTableAvailabilityService eventTableAvailabilityService,
            final CurrentUserService currentUserService,
            final UserShopService userShopService) {
        this.reservationRepository = reservationRepository;
        this.reservationRequestRepository = reservationRequestRepository;
        this.userRepository = userRepository;
        this.tableRepository = tableRepository;
        this.eventRepository = eventRepository;
        this.eventTableAvailabilityService = eventTableAvailabilityService;
        this.currentUserService = currentUserService;
        this.userShopService = userShopService;
    }

    @Override
    public List<Reservation> findAll() {
        return reservationRepository.findAll();
    }

    @Override
    public Reservation getById(final UUID id) {
        if (id == null) {
            throw new IllegalArgumentException("Reservation ID cannot be null");
        }
        return reservationRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Reservation not found with id: " + id));
    }

    @Override
    public Reservation create(final Reservation entity) {
        if (entity.getId() != null) {
            throw new IllegalArgumentException("Reservation ID must be null on create");
        }
        if (entity.getEvent() == null || entity.getEvent().getEventId() == null || entity.getEvent().getEventId().isBlank()) {
            throw new IllegalArgumentException("Event ID is required");
        }
        if (entity.getPartySize() < 1) {
            throw new IllegalArgumentException("partySize must be at least 1");
        }
        entity.setUser(resolveUser(entity.getUser()));
        final Table table = resolveTable(entity.getTable());
        entity.setTable(table);
        if (table.getShop() == null) {
            throw new IllegalArgumentException("Table must belong to a shop");
        }
        final Shop shop = table.getShop();
        entity.setShop(shop);
        assertCanCreateEventReservation(shop);
        final String eventId = entity.getEvent().getEventId();
        final Event event = eventRepository.findById(eventId)
                .orElseThrow(() -> new ResourceNotFoundException("Event not found with id: " + eventId));
        if (event.getShop() == null || !event.getShop().getId().equals(shop.getId())) {
            throw new IllegalArgumentException("Event must belong to the same shop as the table");
        }
        if (table.getCapacity() < entity.getPartySize()) {
            throw new IllegalArgumentException("Table capacity is less than partySize");
        }
        entity.setEvent(event);
        eventTableAvailabilityService.assertHasFreeTable(event);
        entity.setReservationRequest(null);
        assertNoActiveEventBooking(entity.getUser().getId(), eventId);
        return reservationRepository.save(entity);
    }

    @Override
    public Reservation update(final UUID id, final Reservation entity) {
        final Reservation existing = getById(id);
        if (entity.getUser() != null) {
            existing.setUser(resolveUser(entity.getUser()));
        }
        if (entity.getTable() != null) {
            existing.setTable(resolveTable(entity.getTable()));
        }
        return reservationRepository.save(existing);
    }

    @Override
    public void deleteById(final UUID id) {
        if (id == null) {
            throw new IllegalArgumentException("Reservation ID cannot be null");
        }
        if (!reservationRepository.existsById(id)) {
            throw new ResourceNotFoundException("Reservation not found with id: " + id);
        }
        reservationRepository.deleteById(id);
    }

    private void assertNoActiveEventBooking(final UUID userId, final String eventId) {
        if (reservationRequestRepository.existsByUser_IdAndEvent_EventIdAndStatusIn(
                        userId, eventId, List.of(ReservationStatus.PENDING, ReservationStatus.ACCEPTED))
                || reservationRepository.existsByUser_IdAndEvent_EventId(userId, eventId)) {
            throw new ResponseStatusException(
                    HttpStatus.CONFLICT,
                    "This user already has a reservation request or reservation for this event");
        }
    }

    private void assertCanCreateEventReservation(final Shop shop) {
        final User currentUser = currentUserService.requireCurrentUser();
        if (isAdmin(currentUser)) {
            return;
        }
        if (!userShopService.isOwner(currentUser, shop)) {
            throw new ResponseStatusException(HttpStatus.FORBIDDEN, "Only the shop owner can create event reservations");
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

    private User resolveUser(final User ref) {
        if (ref == null || ref.getId() == null) {
            throw new IllegalArgumentException("User is required with an ID");
        }
        return userRepository.findById(ref.getId())
                .orElseThrow(() -> new ResourceNotFoundException("User not found with id: " + ref.getId()));
    }

    private Table resolveTable(final Table ref) {
        if (ref == null || ref.getId() == null) {
            throw new IllegalArgumentException("Table is required with an ID");
        }
        return tableRepository.findById(ref.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Table not found with id: " + ref.getId()));
    }
}
