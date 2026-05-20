package com.coffeeshop.coffeeshop.mapper;

import com.coffeeshop.coffeeshop.model.ReviewComment;
import com.coffeeshop.coffeeshop.model.dto.response.ReviewCommentResponseDto;
import org.springframework.stereotype.Service;

@Service
public class ReviewCommentMapper {

    private final UserMapper userMapper;

    public ReviewCommentMapper(final UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    public ReviewCommentResponseDto toReviewCommentResponse(final ReviewComment comment) {
        if (comment == null) {
            return null;
        }
        final ReviewCommentResponseDto dto = new ReviewCommentResponseDto();
        dto.setId(comment.getId());
        dto.setBody(comment.getBody());
        dto.setCreatedAt(comment.getCreatedAt());
        dto.setUser(userMapper.toUserSummary(comment.getUser()));
        return dto;
    }
}
