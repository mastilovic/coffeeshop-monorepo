package com.coffeeshop.coffeeshop.controller;

import com.coffeeshop.coffeeshop.mapper.RoleMapper;
import com.coffeeshop.coffeeshop.model.dto.request.RoleCreateRequest;
import com.coffeeshop.coffeeshop.model.dto.request.RoleUpdateRequest;
import com.coffeeshop.coffeeshop.model.dto.response.RoleResponseDto;
import com.coffeeshop.coffeeshop.service.RoleService;
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
@RequestMapping("/api/v1/role")
public class RoleController {

    private final RoleService roleService;
    private final RoleMapper roleMapper;

    public RoleController(final RoleService roleService, final RoleMapper roleMapper) {
        this.roleService = roleService;
        this.roleMapper = roleMapper;
    }

    @GetMapping
    public ResponseEntity<List<RoleResponseDto>> getAll() {
        return new ResponseEntity<>(
                roleService.findAll().stream().map(roleMapper::toRoleResponse).collect(Collectors.toList()),
                HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<RoleResponseDto> getById(@PathVariable final UUID id) {
        return new ResponseEntity<>(roleMapper.toRoleResponse(roleService.getById(id)), HttpStatus.OK);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @PostMapping
    public ResponseEntity<RoleResponseDto> create(@RequestBody final RoleCreateRequest request) {
        return new ResponseEntity<>(roleMapper.toRoleResponse(roleService.create(roleMapper.toRole(request))), HttpStatus.CREATED);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @PutMapping("/{id}")
    public ResponseEntity<RoleResponseDto> update(@PathVariable final UUID id, @RequestBody final RoleUpdateRequest request) {
        return new ResponseEntity<>(roleMapper.toRoleResponse(roleService.update(id, roleMapper.toRole(request))), HttpStatus.OK);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable final UUID id) {
        roleService.deleteById(id);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
}
