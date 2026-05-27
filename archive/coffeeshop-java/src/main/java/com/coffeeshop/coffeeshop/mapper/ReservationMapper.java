package com.coffeeshop.coffeeshop.mapper;

import com.coffeeshop.coffeeshop.model.Event;
import com.coffeeshop.coffeeshop.model.Reservation;
import com.coffeeshop.coffeeshop.model.Table;
import com.coffeeshop.coffeeshop.model.User;
import com.coffeeshop.coffeeshop.model.dto.request.ReservationCreateRequest;
import com.coffeeshop.coffeeshop.model.dto.request.ReservationUpdateRequest;
import com.coffeeshop.coffeeshop.model.dto.response.ReservationResponseDto;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;

@Service
public class ReservationMapper {

    private final UserMapper userMapper;
    private final TableMapper tableMapper;
    private final ShopMapper shopMapper;
    private final EventMapper eventMapper;

    public ReservationMapper(
            final UserMapper userMapper,
            final TableMapper tableMapper,
            @Lazy final ShopMapper shopMapper,
            final EventMapper eventMapper) {
        this.userMapper = userMapper;
        this.tableMapper = tableMapper;
        this.shopMapper = shopMapper;
        this.eventMapper = eventMapper;
    }

    public ReservationResponseDto toReservationResponse(final Reservation reservation) {
        if (reservation == null) {
            return null;
        }
        final ReservationResponseDto dto = new ReservationResponseDto();
        dto.setId(reservation.getId());
        dto.setUser(userMapper.toUserSummary(reservation.getUser()));
        dto.setShop(shopMapper.toShopSummary(reservation.getShop()));
        dto.setPartySize(reservation.getPartySize());
        if (reservation.getReservationRequest() != null) {
            dto.setReservationRequestId(reservation.getReservationRequest().getId());
        }
        dto.setTable(tableMapper.toTableSummary(reservation.getTable()));
        eventMapper.mapEventSummary(reservation.getEvent(), dto);
        return dto;
    }

    public Reservation toReservation(final ReservationCreateRequest request) {
        final Reservation reservation = new Reservation();
        if (request.getUserId() != null) {
            final User user = new User();
            user.setId(request.getUserId());
            reservation.setUser(user);
        }
        if (request.getTableId() != null) {
            final Table table = new Table();
            table.setId(request.getTableId());
            reservation.setTable(table);
        }
        if (request.getEventId() != null) {
            final Event event = new Event();
            event.setEventId(request.getEventId());
            reservation.setEvent(event);
        }
        reservation.setPartySize(request.getPartySize());
        return reservation;
    }

    public Reservation toReservation(final ReservationUpdateRequest request) {
        final Reservation reservation = new Reservation();
        if (request.getUserId() != null) {
            final User user = new User();
            user.setId(request.getUserId());
            reservation.setUser(user);
        }
        if (request.getTableId() != null) {
            final Table table = new Table();
            table.setId(request.getTableId());
            reservation.setTable(table);
        }
        return reservation;
    }
}
