package com.coffeeshop.coffeeshop.service.impl;

import com.coffeeshop.coffeeshop.exception.ResourceNotFoundException;
import com.coffeeshop.coffeeshop.model.Contact;
import com.coffeeshop.coffeeshop.model.Shop;
import com.coffeeshop.coffeeshop.repository.ContactRepository;
import com.coffeeshop.coffeeshop.repository.ShopRepository;
import com.coffeeshop.coffeeshop.service.ContactService;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@Service
@Transactional
public class ContactServiceImpl implements ContactService {

    private final ContactRepository contactRepository;
    private final ShopRepository shopRepository;

    public ContactServiceImpl(final ContactRepository contactRepository, final ShopRepository shopRepository) {
        this.contactRepository = contactRepository;
        this.shopRepository = shopRepository;
    }

    @Override
    public List<Contact> findAll() {
        return contactRepository.findAll();
    }

    @Override
    public Contact getById(final UUID id) {
        if (id == null) {
            throw new IllegalArgumentException("Contact ID cannot be null");
        }
        return contactRepository.findById(id)
                .orElseThrow(() -> new ResourceNotFoundException("Contact not found with id: " + id));
    }

    @Override
    public Contact create(final Contact entity) {
        if (entity.getId() != null) {
            throw new IllegalArgumentException("Contact ID must be null on create");
        }
        entity.setShop(resolveShop(entity.getShop()));
        return contactRepository.save(entity);
    }

    @Override
    public Contact update(final UUID id, final Contact entity) {
        final Contact existing = getById(id);
        if (entity.getShop() != null) {
            existing.setShop(resolveShop(entity.getShop()));
        }
        return contactRepository.save(existing);
    }

    @Override
    public void deleteById(final UUID id) {
        if (id == null) {
            throw new IllegalArgumentException("Contact ID cannot be null");
        }
        if (!contactRepository.existsById(id)) {
            throw new ResourceNotFoundException("Contact not found with id: " + id);
        }
        contactRepository.deleteById(id);
    }

    private Shop resolveShop(final Shop ref) {
        if (ref == null || ref.getId() == null) {
            throw new IllegalArgumentException("Shop is required with an ID");
        }
        return shopRepository.findById(ref.getId())
                .orElseThrow(() -> new ResourceNotFoundException("Shop not found with id: " + ref.getId()));
    }
}
