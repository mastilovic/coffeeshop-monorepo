package com.coffeeshop.coffeeshop.mapper;

import com.coffeeshop.coffeeshop.model.ReservationRequest;
import com.coffeeshop.coffeeshop.model.dto.response.ReservationRequestResponseDto;
import org.springframework.context.annotation.Lazy;
import org.springframework.stereotype.Service;

@Service
public class ReservationRequestMapper {

    private final UserMapper userMapper;
    private final ShopMapper shopMapper;
    private final EventMapper eventMapper;

    public ReservationRequestMapper(
            final UserMapper userMapper,
            @Lazy final ShopMapper shopMapper,
            final EventMapper eventMapper) {
        this.userMapper = userMapper;
        this.shopMapper = shopMapper;
        this.eventMapper = eventMapper;
    }

    public ReservationRequestResponseDto toResponse(final ReservationRequest request) {
        if (request == null) {
            return null;
        }
        final ReservationRequestResponseDto dto = new ReservationRequestResponseDto();
        dto.setId(request.getId());
        dto.setUser(userMapper.toUserSummary(request.getUser()));
        dto.setShop(shopMapper.toShopSummary(request.getShop()));
        dto.setPartySize(request.getPartySize());
        dto.setStatus(request.getStatus());
        if (request.getReservation() != null) {
            dto.setReservationId(request.getReservation().getId());
        }
        eventMapper.mapEventSummary(request.getEvent(), dto);
        return dto;
    }
}
