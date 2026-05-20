package com.coffeeshop.coffeeshop.controller;

import com.coffeeshop.coffeeshop.mapper.ContactMapper;
import com.coffeeshop.coffeeshop.model.dto.request.ContactCreateRequest;
import com.coffeeshop.coffeeshop.model.dto.request.ContactUpdateRequest;
import com.coffeeshop.coffeeshop.model.dto.response.ContactResponseDto;
import com.coffeeshop.coffeeshop.service.ContactService;
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
@RequestMapping("/api/v1/contact")
public class ContactController {

    private final ContactService contactService;
    private final ContactMapper contactMapper;

    public ContactController(final ContactService contactService, final ContactMapper contactMapper) {
        this.contactService = contactService;
        this.contactMapper = contactMapper;
    }

    @GetMapping
    public ResponseEntity<List<ContactResponseDto>> getAll() {
        return new ResponseEntity<>(
                contactService.findAll().stream().map(contactMapper::toContactResponse).collect(Collectors.toList()),
                HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ContactResponseDto> getById(@PathVariable final UUID id) {
        return new ResponseEntity<>(contactMapper.toContactResponse(contactService.getById(id)), HttpStatus.OK);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @PostMapping
    public ResponseEntity<ContactResponseDto> create(@RequestBody final ContactCreateRequest request) {
        return new ResponseEntity<>(contactMapper.toContactResponse(contactService.create(contactMapper.toContact(request))), HttpStatus.CREATED);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @PutMapping("/{id}")
    public ResponseEntity<ContactResponseDto> update(@PathVariable final UUID id, @RequestBody final ContactUpdateRequest request) {
        return new ResponseEntity<>(contactMapper.toContactResponse(contactService.update(id, contactMapper.toContact(request))), HttpStatus.OK);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable final UUID id) {
        contactService.deleteById(id);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
}
