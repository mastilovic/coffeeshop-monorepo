package com.coffeeshop.coffeeshop.service.impl;

import com.coffeeshop.coffeeshop.exception.ResourceNotFoundException;
import com.coffeeshop.coffeeshop.model.LoyaltyPlan;
import com.coffeeshop.coffeeshop.repository.LoyaltyPlanRepository;
import com.coffeeshop.coffeeshop.service.LoyaltyPlanService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@Transactional
public class LoyaltyPlanServiceImpl implements LoyaltyPlanService {

    private final LoyaltyPlanRepository loyaltyPlanRepository;

    public LoyaltyPlanServiceImpl(final LoyaltyPlanRepository loyaltyPlanRepository) {
        this.loyaltyPlanRepository = loyaltyPlanRepository;
    }

    @Override
    public List<LoyaltyPlan> findAll() {
        return loyaltyPlanRepository.findAll();
    }

    @Override
    public LoyaltyPlan getById(final UUID id) {
        if (id == null) {
            throw new IllegalArgumentException("Loyalty plan ID cannot be null");
        }
        return loyaltyPlanRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Loyalty plan not found with id: " + id));
    }

    @Override
    public LoyaltyPlan create(final LoyaltyPlan entity) {
        if (entity.getId() != null) {
            throw new IllegalArgumentException("Loyalty plan ID must be null on create");
        }
        return loyaltyPlanRepository.save(entity);
    }

    @Override
    public LoyaltyPlan update(final UUID id, final LoyaltyPlan entity) {
        final LoyaltyPlan existing = getById(id);
        if (entity.getName() != null) {
            existing.setName(entity.getName());
        }
        if (entity.getDescription() != null) {
            existing.setDescription(entity.getDescription());
        }
        if (entity.getType() != null) {
            existing.setType(entity.getType());
        }
        return loyaltyPlanRepository.save(existing);
    }

    @Override
    public void deleteById(final UUID id) {
        if (id == null) {
            throw new IllegalArgumentException("Loyalty plan ID cannot be null");
        }
        if (!loyaltyPlanRepository.existsById(id)) {
            throw new ResourceNotFoundException("Loyalty plan not found with id: " + id);
        }
        loyaltyPlanRepository.deleteById(id);
    }
}
