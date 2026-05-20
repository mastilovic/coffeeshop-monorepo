package com.coffeeshop.coffeeshop.controller;

import com.coffeeshop.coffeeshop.mapper.CommunityPostMapper;
import com.coffeeshop.coffeeshop.model.CommunityPost;
import com.coffeeshop.coffeeshop.model.dto.request.CommunityPostCreateRequest;
import com.coffeeshop.coffeeshop.model.dto.response.CommunityPostResponseDto;
import com.coffeeshop.coffeeshop.model.dto.response.PageResponseDto;
import com.coffeeshop.coffeeshop.service.CommunityPostService;
import io.swagger.v3.oas.annotations.security.SecurityRequirement;
import jakarta.validation.Valid;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.security.access.prepost.PreAuthorize;
import org.springframework.web.bind.annotation.*;

import java.util.UUID;
import java.util.stream.Collectors;

@RestController
@CrossOrigin(origins = "*")
@RequestMapping("/api/v1/shop/{shopId}/community")
public class ShopCommunityController {

    private final CommunityPostService communityPostService;
    private final CommunityPostMapper communityPostMapper;

    public ShopCommunityController(
            final CommunityPostService communityPostService,
            final CommunityPostMapper communityPostMapper) {
        this.communityPostService = communityPostService;
        this.communityPostMapper = communityPostMapper;
    }

    @GetMapping("/posts")
    public ResponseEntity<PageResponseDto<CommunityPostResponseDto>> getPosts(
            @PathVariable final UUID shopId,
            @RequestParam(defaultValue = "0") final int page,
            @RequestParam(defaultValue = "20") final int size) {
        final Page<CommunityPost> result = communityPostService.findByShop(shopId, PageRequest.of(page, size));
        final PageResponseDto<CommunityPostResponseDto> response = new PageResponseDto<>(
                result.getContent().stream()
                        .map(communityPostMapper::toCommunityPostResponse)
                        .collect(Collectors.toList()),
                result.getNumber(),
                result.getSize(),
                result.getTotalElements(),
                result.getTotalPages());
        return new ResponseEntity<>(response, HttpStatus.OK);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @PostMapping("/announcements")
    public ResponseEntity<CommunityPostResponseDto> createAnnouncement(
            @PathVariable final UUID shopId,
            @Valid @RequestBody final CommunityPostCreateRequest request) {
        final CommunityPost post = communityPostService.createAnnouncement(shopId, request.getBody());
        return new ResponseEntity<>(communityPostMapper.toCommunityPostResponse(post), HttpStatus.CREATED);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @DeleteMapping("/posts/{postId}")
    public ResponseEntity<Void> deletePost(
            @PathVariable final UUID shopId,
            @PathVariable final UUID postId) {
        communityPostService.delete(shopId, postId);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
}
