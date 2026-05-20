package com.coffeeshop.coffeeshop.repository;

import com.coffeeshop.coffeeshop.model.LoyaltyPlan;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.UUID;

@Repository
public interface LoyaltyPlanRepository extends JpaRepository<LoyaltyPlan, UUID> {
}
