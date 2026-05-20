package com.coffeeshop.coffeeshop.mapper;

import com.coffeeshop.coffeeshop.model.CommunityPost;
import com.coffeeshop.coffeeshop.model.dto.response.CommunityPostResponseDto;
import org.springframework.stereotype.Service;

@Service
public class CommunityPostMapper {

    private final UserMapper userMapper;

    public CommunityPostMapper(final UserMapper userMapper) {
        this.userMapper = userMapper;
    }

    public CommunityPostResponseDto toCommunityPostResponse(final CommunityPost post) {
        if (post == null) {
            return null;
        }
        final CommunityPostResponseDto dto = new CommunityPostResponseDto();
        dto.setId(post.getId());
        dto.setBody(post.getBody());
        dto.setType(post.getType());
        dto.setPinned(post.isPinned());
        dto.setCreatedAt(post.getCreatedAt());
        dto.setAuthor(userMapper.toUserSummary(post.getAuthor()));
        if (post.getShop() != null) {
            dto.setShopId(post.getShop().getId());
        }
        return dto;
    }
}
