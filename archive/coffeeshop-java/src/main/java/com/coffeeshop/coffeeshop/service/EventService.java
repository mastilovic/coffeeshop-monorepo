package com.coffeeshop.coffeeshop.service;

import com.coffeeshop.coffeeshop.model.Event;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;
import java.util.UUID;

public interface EventService {

    List<Event> findAll();

    Page<Event> search(Optional<String> query, Optional<LocalDate> dateFrom, Optional<LocalDate> dateTo, Pageable pageable);

    List<Event> findByShopId(UUID shopId);

    Event getById(String eventId);

    Event create(Event entity);

    Event update(String eventId, Event entity);

    void deleteById(String eventId);
}
