package com.coffeeshop.coffeeshop.service;

import com.coffeeshop.coffeeshop.model.CommunityPost;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;

import java.util.UUID;

public interface CommunityPostService {

    Page<CommunityPost> findByShop(UUID shopId, Pageable pageable);

    CommunityPost createAnnouncement(UUID shopId, String body);

    void delete(UUID shopId, UUID postId);
}
