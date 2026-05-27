package com.coffeeshop.coffeeshop.mapper;

import com.coffeeshop.coffeeshop.model.LoyaltyPlan;
import com.coffeeshop.coffeeshop.model.dto.request.LoyaltyPlanCreateRequest;
import com.coffeeshop.coffeeshop.model.dto.request.LoyaltyPlanUpdateRequest;
import com.coffeeshop.coffeeshop.model.dto.response.LoyaltyPlanResponseDto;
import org.springframework.stereotype.Service;

@Service
public class LoyaltyPlanMapper {

    public LoyaltyPlanResponseDto toLoyaltyPlanResponse(final LoyaltyPlan plan) {
        if (plan == null) {
            return null;
        }
        final LoyaltyPlanResponseDto dto = new LoyaltyPlanResponseDto();
        dto.setId(plan.getId());
        dto.setName(plan.getName());
        dto.setDescription(plan.getDescription());
        dto.setType(plan.getType());
        return dto;
    }

    public LoyaltyPlan toLoyaltyPlan(final LoyaltyPlanCreateRequest request) {
        final LoyaltyPlan plan = new LoyaltyPlan();
        plan.setName(request.getName());
        plan.setDescription(request.getDescription());
        plan.setType(request.getType());
        return plan;
    }

    public LoyaltyPlan toLoyaltyPlan(final LoyaltyPlanUpdateRequest request) {
        final LoyaltyPlan plan = new LoyaltyPlan();
        plan.setName(request.getName());
        plan.setDescription(request.getDescription());
        plan.setType(request.getType());
        return plan;
    }
}
