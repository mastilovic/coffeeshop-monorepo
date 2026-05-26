package com.coffeeshop.coffeeshop.controller;

import com.coffeeshop.coffeeshop.mapper.LoyaltyPlanMapper;
import com.coffeeshop.coffeeshop.model.dto.request.LoyaltyPlanCreateRequest;
import com.coffeeshop.coffeeshop.model.dto.request.LoyaltyPlanUpdateRequest;
import com.coffeeshop.coffeeshop.model.dto.response.LoyaltyPlanResponseDto;
import com.coffeeshop.coffeeshop.service.LoyaltyPlanService;
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
@RequestMapping("/api/v1/loyalty-plan")
public class LoyaltyPlanController {

    private final LoyaltyPlanService loyaltyPlanService;
    private final LoyaltyPlanMapper loyaltyPlanMapper;

    public LoyaltyPlanController(final LoyaltyPlanService loyaltyPlanService, final LoyaltyPlanMapper loyaltyPlanMapper) {
        this.loyaltyPlanService = loyaltyPlanService;
        this.loyaltyPlanMapper = loyaltyPlanMapper;
    }

    @GetMapping
    public ResponseEntity<List<LoyaltyPlanResponseDto>> getAll() {
        return new ResponseEntity<>(
                loyaltyPlanService.findAll().stream().map(loyaltyPlanMapper::toLoyaltyPlanResponse).collect(Collectors.toList()),
                HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<LoyaltyPlanResponseDto> getById(@PathVariable final UUID id) {
        return new ResponseEntity<>(loyaltyPlanMapper.toLoyaltyPlanResponse(loyaltyPlanService.getById(id)), HttpStatus.OK);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @PostMapping
    public ResponseEntity<LoyaltyPlanResponseDto> create(@RequestBody final LoyaltyPlanCreateRequest request) {
        return new ResponseEntity<>(loyaltyPlanMapper.toLoyaltyPlanResponse(loyaltyPlanService.create(loyaltyPlanMapper.toLoyaltyPlan(request))), HttpStatus.CREATED);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @PutMapping("/{id}")
    public ResponseEntity<LoyaltyPlanResponseDto> update(@PathVariable final UUID id, @RequestBody final LoyaltyPlanUpdateRequest request) {
        return new ResponseEntity<>(loyaltyPlanMapper.toLoyaltyPlanResponse(loyaltyPlanService.update(id, loyaltyPlanMapper.toLoyaltyPlan(request))), HttpStatus.OK);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable final UUID id) {
        loyaltyPlanService.deleteById(id);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
}
