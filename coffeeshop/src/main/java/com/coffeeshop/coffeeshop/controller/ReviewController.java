package com.coffeeshop.coffeeshop.controller;

import com.coffeeshop.coffeeshop.mapper.ReviewCommentMapper;
import com.coffeeshop.coffeeshop.mapper.ReviewMapper;
import com.coffeeshop.coffeeshop.model.dto.request.ReviewCommentCreateRequest;
import com.coffeeshop.coffeeshop.model.dto.request.ReviewCreateRequest;
import com.coffeeshop.coffeeshop.model.dto.request.ReviewUpdateRequest;
import com.coffeeshop.coffeeshop.model.dto.response.ReviewCommentResponseDto;
import com.coffeeshop.coffeeshop.model.dto.response.ReviewResponseDto;
import com.coffeeshop.coffeeshop.service.ReviewCommentService;
import com.coffeeshop.coffeeshop.service.ReviewService;
import jakarta.validation.Valid;
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
@RequestMapping("/api/v1/review")
public class ReviewController {

    private final ReviewService reviewService;
    private final ReviewMapper reviewMapper;
    private final ReviewCommentService reviewCommentService;
    private final ReviewCommentMapper reviewCommentMapper;

    public ReviewController(
            final ReviewService reviewService,
            final ReviewMapper reviewMapper,
            final ReviewCommentService reviewCommentService,
            final ReviewCommentMapper reviewCommentMapper) {
        this.reviewService = reviewService;
        this.reviewMapper = reviewMapper;
        this.reviewCommentService = reviewCommentService;
        this.reviewCommentMapper = reviewCommentMapper;
    }

    @GetMapping
    public ResponseEntity<List<ReviewResponseDto>> getAll() {
        return new ResponseEntity<>(
                reviewService.findAll().stream().map(reviewMapper::toReviewResponse).collect(Collectors.toList()),
                HttpStatus.OK);
    }

    @GetMapping("/{id}")
    public ResponseEntity<ReviewResponseDto> getById(@PathVariable final UUID id) {
        return new ResponseEntity<>(reviewMapper.toReviewResponse(reviewService.getById(id)), HttpStatus.OK);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @PostMapping
    public ResponseEntity<ReviewResponseDto> create(@Valid @RequestBody final ReviewCreateRequest request) {
        return new ResponseEntity<>(reviewMapper.toReviewResponse(reviewService.create(reviewMapper.toReview(request))), HttpStatus.CREATED);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @PutMapping("/{id}")
    public ResponseEntity<ReviewResponseDto> update(@PathVariable final UUID id, @Valid @RequestBody final ReviewUpdateRequest request) {
        return new ResponseEntity<>(
                reviewMapper.toReviewResponse(reviewService.update(id, reviewMapper.toReview(request), request)),
                HttpStatus.OK);
    }

    @GetMapping("/{reviewId}/comments")
    public ResponseEntity<List<ReviewCommentResponseDto>> getComments(@PathVariable final UUID reviewId) {
        return new ResponseEntity<>(
                reviewCommentService.findByReviewId(reviewId).stream()
                        .map(reviewCommentMapper::toReviewCommentResponse)
                        .collect(Collectors.toList()),
                HttpStatus.OK);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @PostMapping("/{reviewId}/comments")
    public ResponseEntity<ReviewCommentResponseDto> createComment(
            @PathVariable final UUID reviewId,
            @Valid @RequestBody final ReviewCommentCreateRequest request) {
        return new ResponseEntity<>(
                reviewCommentMapper.toReviewCommentResponse(
                        reviewCommentService.create(reviewId, request.getBody())),
                HttpStatus.CREATED);
    }

    @PreAuthorize("isAuthenticated()")
    @SecurityRequirement(name = "bearer-jwt")
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable final UUID id) {
        reviewService.deleteById(id);
        return new ResponseEntity<>(HttpStatus.NO_CONTENT);
    }
}
