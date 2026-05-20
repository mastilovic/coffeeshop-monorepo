package com.coffeeshop.coffeeshop.controller;

import com.coffeeshop.coffeeshop.mapper.ReservationRequestMapper;
import com.coffeeshop.coffeeshop.model.dto.request.ReservationAcceptRequest;
import com.coffeeshop.coffeeshop.model.dto.request.ReservationRequestCreateRequest;
import com.coffeeshop.coffeeshop.model.dto.response.ReservationRequestResponseDto;
import com.coffeeshop.coffeeshop.service.ReservationRequestService;
import org.springframework.http.HttpStatus;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Optional;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@CrossOrigin(origins = "*")
@RequestMapping("/api/v1/reservation-request")
public class ReservationRequestController {

    private final ReservationRequestService reservationRequestService;
    private final ReservationRequestMapper reservationRequestMapper;

    public ReservationRequestController(
            final ReservationRequestService reservationRequestService,
            final ReservationRequestMapper reservationRequestMapper) {
        this.reservationRequestService = reservationRequestService;
        this.reservationRequestMapper = reservationRequestMapper;
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @GetMapping
    public ResponseEntity<List<ReservationRequestResponseDto>> list(
            @RequestParam(required = false) final UUID shopId) {
        return new ResponseEntity<>(
                reservationRequestService.findForCurrentUser(Optional.ofNullable(shopId)).stream()
                        .map(reservationRequestMapper::toResponse)
                        .collect(Collectors.toList()),
                HttpStatus.OK);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @PostMapping
    public ResponseEntity<ReservationRequestResponseDto> createRequest(@RequestBody final ReservationRequestCreateRequest request) {
        return new ResponseEntity<>(
                reservationRequestMapper.toResponse(
                        reservationRequestService.createRequest(
                                request.getUserId(),
                                request.getShopId(),
                                request.getEventId(),
                                request.getPartySize())),
                HttpStatus.CREATED);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @PostMapping("/{id}/accept")
    public ResponseEntity<ReservationRequestResponseDto> accept(
            @PathVariable final UUID id,
            @RequestBody final ReservationAcceptRequest request) {
        return new ResponseEntity<>(
                reservationRequestMapper.toResponse(reservationRequestService.accept(id, request.getTableId())),
                HttpStatus.OK);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @PostMapping("/{id}/deny")
    public ResponseEntity<ReservationRequestResponseDto> deny(@PathVariable final UUID id) {
        return new ResponseEntity<>(
                reservationRequestMapper.toResponse(reservationRequestService.deny(id)),
                HttpStatus.OK);
    }
}
