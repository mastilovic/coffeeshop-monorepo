package com.coffeeshop.coffeeshop.controller;

import com.coffeeshop.coffeeshop.mapper.TableMapper;
import com.coffeeshop.coffeeshop.model.Table;
import com.coffeeshop.coffeeshop.model.dto.request.TableCreateRequest;
import com.coffeeshop.coffeeshop.model.dto.request.TableUpdateRequest;
import com.coffeeshop.coffeeshop.model.dto.response.TableResponseDto;
import com.coffeeshop.coffeeshop.service.TableService;
import org.springframework.http.HttpStatus;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@CrossOrigin(origins = "*")
@RequestMapping("/api/v1/table")
public class TableController {

    private final TableService tableService;
    private final TableMapper tableMapper;

    public TableController(final TableService tableService, final TableMapper tableMapper) {
        this.tableService = tableService;
        this.tableMapper = tableMapper;
    }

    @GetMapping
    public ResponseEntity<List<TableResponseDto>> getAll() {
        return new ResponseEntity<>(
                tableService.findAll().stream().map(tableMapper::toTableResponse).collect(Collectors.toList()),
                HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<TableResponseDto> getById(@PathVariable final UUID id) {
        return new ResponseEntity<>(tableMapper.toTableResponse(tableService.getById(id)), HttpStatus.OK);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @PostMapping
    public ResponseEntity<TableResponseDto> create(@RequestBody final TableCreateRequest request) {
        return new ResponseEntity<>(tableMapper.toTableResponse(tableService.create(tableMapper.toTable(request))), HttpStatus.CREATED);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @PutMapping("/{id}")
    public ResponseEntity<TableResponseDto> update(@PathVariable final UUID id, @RequestBody final TableUpdateRequest request) {
        final Table existing = tableService.getById(id);
        return new ResponseEntity<>(tableMapper.toTableResponse(tableService.update(id, tableMapper.toTable(request, existing))), HttpStatus.OK);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable final UUID id) {
        tableService.deleteById(id);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
}
