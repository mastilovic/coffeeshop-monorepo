package com.coffeeshop.coffeeshop.repository;

import com.coffeeshop.coffeeshop.model.CommunityPost;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface CommunityPostRepository extends JpaRepository<CommunityPost, UUID> {

    Page<CommunityPost> findByShop_IdOrderByPinnedDescCreatedAtDesc(UUID shopId, Pageable pageable);
}
