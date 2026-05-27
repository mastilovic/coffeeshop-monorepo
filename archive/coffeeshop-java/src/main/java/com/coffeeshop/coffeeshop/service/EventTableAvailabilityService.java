package com.coffeeshop.coffeeshop.service;

import com.coffeeshop.coffeeshop.model.Event;
import com.coffeeshop.coffeeshop.repository.ReservationRepository;
import com.coffeeshop.coffeeshop.repository.TableRepository;
import org.springframework.http.HttpStatus;
import org.springframework.stereotype.Service;
import org.springframework.web.server.ResponseStatusException;

@Service
public class EventTableAvailabilityService {

    private final ReservationRepository reservationRepository;
    private final TableRepository tableRepository;

    public EventTableAvailabilityService(
            final ReservationRepository reservationRepository,
            final TableRepository tableRepository) {
        this.reservationRepository = reservationRepository;
        this.tableRepository = tableRepository;
    }

    public AvailabilitySnapshot summarize(final Event event) {
        if (event == null || event.getShop() == null || event.getShop().getId() == null) {
            throw new IllegalArgumentException("Event must belong to a shop");
        }
        if (event.getEventId() == null || event.getEventId().isBlank()) {
            throw new IllegalArgumentException("Event ID is required");
        }
        final long totalTables = tableRepository.countByShop_Id(event.getShop().getId());
        final long reservedTables = reservationRepository.countByEvent_EventId(event.getEventId());
        return new AvailabilitySnapshot(totalTables, reservedTables);
    }

    public void assertHasFreeTable(final Event event) {
        final AvailabilitySnapshot snapshot = summarize(event);
        if (snapshot.totalTables() < 1 || snapshot.freeTables() < 1) {
            throw new ResponseStatusException(HttpStatus.CONFLICT, "No tables left for this event");
        }
    }

    public record AvailabilitySnapshot(long totalTables, long reservedTables) {
        public long freeTables() {
            return Math.max(0, totalTables - reservedTables);
        }

        public boolean isFull() {
            return freeTables() <= 0;
        }
    }
}
