package com.coffeeshop.coffeeshop.controller;

import com.coffeeshop.coffeeshop.mapper.ReservationMapper;
import com.coffeeshop.coffeeshop.model.dto.request.ReservationCreateRequest;
import com.coffeeshop.coffeeshop.model.dto.request.ReservationUpdateRequest;
import com.coffeeshop.coffeeshop.model.dto.response.ReservationResponseDto;
import com.coffeeshop.coffeeshop.service.ReservationService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@CrossOrigin(origins = "*")
@RequestMapping("/api/v1/reservation")
public class ReservationController {

    private final ReservationService reservationService;
    private final ReservationMapper reservationMapper;

    public ReservationController(final ReservationService reservationService, final ReservationMapper reservationMapper) {
        this.reservationService = reservationService;
        this.reservationMapper = reservationMapper;
    }

    @GetMapping
    public ResponseEntity<List<ReservationResponseDto>> getAll() {
        return new ResponseEntity<>(
                reservationService.findAll().stream().map(reservationMapper::toReservationResponse).collect(Collectors.toList()),
                HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ReservationResponseDto> getById(@PathVariable final UUID id) {
        return new ResponseEntity<>(reservationMapper.toReservationResponse(reservationService.getById(id)), HttpStatus.OK);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @PostMapping
    public ResponseEntity<ReservationResponseDto> create(@RequestBody final ReservationCreateRequest request) {
        return new ResponseEntity<>(reservationMapper.toReservationResponse(reservationService.create(reservationMapper.toReservation(request))), HttpStatus.CREATED);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @PutMapping("/{id}")
    public ResponseEntity<ReservationResponseDto> update(@PathVariable final UUID id, @RequestBody final ReservationUpdateRequest request) {
        return new ResponseEntity<>(reservationMapper.toReservationResponse(reservationService.update(id, reservationMapper.toReservation(request))), HttpStatus.OK);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable final UUID id) {
        reservationService.deleteById(id);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
}
