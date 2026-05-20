package com.coffeeshop.coffeeshop.service;

import com.coffeeshop.coffeeshop.model.Table;

import java.util.List;
import java.util.UUID;

public interface TableService {

    List<Table> findAll();

    Table getById(UUID id);

    Table create(Table entity);

    Table update(UUID id, Table entity);

    void deleteById(UUID id);
}
