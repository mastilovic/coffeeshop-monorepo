package com.coffeeshop.coffeeshop.controller;

import com.coffeeshop.coffeeshop.mapper.EventMapper;
import com.coffeeshop.coffeeshop.model.Event;
import com.coffeeshop.coffeeshop.model.dto.request.EventCreateRequest;
import com.coffeeshop.coffeeshop.model.dto.request.EventUpdateRequest;
import com.coffeeshop.coffeeshop.model.dto.response.EventResponseDto;
import com.coffeeshop.coffeeshop.model.dto.response.PageResponseDto;
import com.coffeeshop.coffeeshop.service.EventService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Sort;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.format.DateTimeParseException;
import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@CrossOrigin(origins = "*")
@RequestMapping("/api/v1/event")
public class EventController {

    private final EventService eventService;
    private final EventMapper eventMapper;

    public EventController(final EventService eventService, final EventMapper eventMapper) {
        this.eventService = eventService;
        this.eventMapper = eventMapper;
    }

    private static Optional<LocalDate> parseDateParam(final String value, final String paramName) {
        if (value == null || value.isBlank()) {
            return Optional.empty();
        }
        try {
            return Optional.of(LocalDate.parse(value.trim()));
        } catch (final DateTimeParseException ex) {
            throw new IllegalArgumentException("Invalid " + paramName + " format, expected yyyy-MM-dd");
        }
    }

    @GetMapping
    public ResponseEntity<?> getAll(
            @RequestParam(required = false) final UUID shopId,
            @RequestParam(required = false) final String q,
            @RequestParam(required = false) final String dateFrom,
            @RequestParam(required = false) final String dateTo,
            @RequestParam(defaultValue = "0") final int page,
            @RequestParam(defaultValue = "10") final int size) {
        if (shopId != null) {
            final List<EventResponseDto> events = eventService.findByShopId(shopId).stream()
                    .map(eventMapper::toEventResponse)
                    .collect(Collectors.toList());
            return new ResponseEntity<>(events, HttpStatus.OK);
        }

        final Optional<LocalDate> from = parseDateParam(dateFrom, "dateFrom");
        final Optional<LocalDate> to = parseDateParam(dateTo, "dateTo");
        if (from.isPresent() && to.isPresent() && from.get().isAfter(to.get())) {
            throw new IllegalArgumentException("dateFrom must not be after dateTo");
        }

        final PageRequest pageable = PageRequest.of(
                page,
                size,
                Sort.by(Sort.Direction.DESC, "eventDate"));
        final Page<Event> result = eventService.search(Optional.ofNullable(q), from, to, pageable);
        final PageResponseDto<EventResponseDto> response = new PageResponseDto<>(
                result.getContent().stream()
                        .map(eventMapper::toEventResponse)
                        .collect(Collectors.toList()),
                result.getNumber(),
                result.getSize(),
                result.getTotalElements(),
                result.getTotalPages());
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @GetMapping("/{eventId}")
    public ResponseEntity<EventResponseDto> getById(@PathVariable final String eventId) {
        return new ResponseEntity<>(eventMapper.toEventResponse(eventService.getById(eventId)), HttpStatus.OK);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @PostMapping
    public ResponseEntity<EventResponseDto> create(@RequestBody final EventCreateRequest request) {
        return new ResponseEntity<>(eventMapper.toEventResponse(eventService.create(eventMapper.toEvent(request))), HttpStatus.CREATED);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @PutMapping("/{eventId}")
    public ResponseEntity<EventResponseDto> update(@PathVariable final String eventId, @RequestBody final EventUpdateRequest request) {
        return new ResponseEntity<>(eventMapper.toEventResponse(eventService.update(eventId, eventMapper.toEvent(request))), HttpStatus.OK);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @DeleteMapping("/{eventId}")
    public ResponseEntity<Void> delete(@PathVariable final String eventId) {
        eventService.deleteById(eventId);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
}
