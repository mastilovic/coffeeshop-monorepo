package com.coffeeshop.coffeeshop.repository;

import com.coffeeshop.coffeeshop.model.Review;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;
import java.util.UUID;

@Repository
public interface ReviewRepository extends JpaRepository<Review, UUID> {

    Optional<Review> findByUser_IdAndShop_Id(UUID userId, UUID shopId);
}
