package com.coffeeshop.coffeeshop.service;

import com.coffeeshop.coffeeshop.model.Contact;

import java.util.List;
import java.util.UUID;

public interface ContactService {

    List<Contact> findAll();

    Contact getById(UUID id);

    Contact create(Contact entity);

    Contact update(UUID id, Contact entity);

    void deleteById(UUID id);
}
