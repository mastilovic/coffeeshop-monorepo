package com.coffeeshop.coffeeshop.mapper;

import com.coffeeshop.coffeeshop.model.Event;
import com.coffeeshop.coffeeshop.model.Shop;
import com.coffeeshop.coffeeshop.model.dto.request.EventCreateRequest;
import com.coffeeshop.coffeeshop.model.dto.request.EventUpdateRequest;
import com.coffeeshop.coffeeshop.model.dto.response.EventResponseDto;
import com.coffeeshop.coffeeshop.model.dto.response.ReservationRequestResponseDto;
import com.coffeeshop.coffeeshop.model.dto.response.ReservationResponseDto;
import com.coffeeshop.coffeeshop.service.EventTableAvailabilityService;
import org.springframework.stereotype.Service;

@Service
public class EventMapper {

    private final EventTableAvailabilityService eventTableAvailabilityService;

    public EventMapper(final EventTableAvailabilityService eventTableAvailabilityService) {
        this.eventTableAvailabilityService = eventTableAvailabilityService;
    }

    public void mapEventSummary(
            final Event event,
            final ReservationRequestResponseDto dto) {
        if (event == null || dto == null) {
            return;
        }
        dto.setEventId(event.getEventId());
        dto.setEventName(event.getEventName());
        dto.setEventDate(event.getEventDate());
    }

    public void mapEventSummary(
            final Event event,
            final ReservationResponseDto dto) {
        if (event == null || dto == null) {
            return;
        }
        dto.setEventId(event.getEventId());
        dto.setEventName(event.getEventName());
        dto.setEventDate(event.getEventDate());
    }

    public EventResponseDto toEventResponse(final Event event) {
        if (event == null) {
            return null;
        }
        final EventResponseDto dto = new EventResponseDto();
        dto.setEventId(event.getEventId());
        dto.setEventName(event.getEventName());
        dto.setEventDate(event.getEventDate());
        dto.setDescription(event.getDescription());
        if (event.getShop() != null) {
            dto.setShopId(event.getShop().getId());
            dto.setShopName(event.getShop().getName());
            dto.setShopCity(event.getShop().getCity());
            final EventTableAvailabilityService.AvailabilitySnapshot snapshot =
                    eventTableAvailabilityService.summarize(event);
            dto.setTotalTables(snapshot.totalTables());
            dto.setReservedTables(snapshot.reservedTables());
            dto.setFreeTables(snapshot.freeTables());
            dto.setIsFull(snapshot.isFull());
        }
        return dto;
    }

    public Event toEvent(final EventCreateRequest request) {
        final Event event = new Event();
        event.setEventName(request.getEventName());
        event.setEventDate(request.getEventDate());
        event.setDescription(request.getDescription());
        if (request.getShopId() != null) {
            final Shop shop = new Shop();
            shop.setId(request.getShopId());
            event.setShop(shop);
        }
        return event;
    }

    public Event toEvent(final EventUpdateRequest request) {
        final Event event = new Event();
        event.setEventName(request.getEventName());
        event.setEventDate(request.getEventDate());
        event.setDescription(request.getDescription());
        if (request.getShopId() != null) {
            final Shop shop = new Shop();
            shop.setId(request.getShopId());
            event.setShop(shop);
        }
        return event;
    }
}
