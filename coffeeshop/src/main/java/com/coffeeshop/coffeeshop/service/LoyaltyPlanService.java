package com.coffeeshop.coffeeshop.service;

import com.coffeeshop.coffeeshop.model.LoyaltyPlan;

import java.util.List;
import java.util.UUID;

public interface LoyaltyPlanService {

    List<LoyaltyPlan> findAll();

    LoyaltyPlan getById(UUID id);

    LoyaltyPlan create(LoyaltyPlan entity);

    LoyaltyPlan update(UUID id, LoyaltyPlan entity);

    void deleteById(UUID id);
}
