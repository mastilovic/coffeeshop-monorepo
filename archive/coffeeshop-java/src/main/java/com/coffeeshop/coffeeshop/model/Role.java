package com.coffeeshop.coffeeshop.model;

import com.coffeeshop.coffeeshop.model.enums.RoleType;
import jakarta.persistence.*;
import jakarta.persistence.Table;

import java.util.UUID;

@Entity
@Table(name = "roles")
public class Role {
    @Id
    @GeneratedValue(strategy = GenerationType.AUTO)
    private UUID id;
    private String name;
    private RoleType type;

    public Role() {
    }

    public Role(UUID id, String name, RoleType type) {
        this.id = id;
        this.name = name;
        this.type = type;
    }

    public UUID getId() {
        return id;
    }

    public void setId(UUID id) {
        this.id = id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public RoleType getType() {
        return type;
    }

    public void setType(RoleType type) {
        this.type = type;
    }
}
