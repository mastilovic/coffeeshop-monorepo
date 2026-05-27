package com.coffeeshop.coffeeshop.mapper;

import com.coffeeshop.coffeeshop.model.Contact;
import com.coffeeshop.coffeeshop.model.Shop;
import com.coffeeshop.coffeeshop.model.dto.request.ContactCreateRequest;
import com.coffeeshop.coffeeshop.model.dto.request.ContactUpdateRequest;
import com.coffeeshop.coffeeshop.model.dto.response.ContactResponseDto;
import org.springframework.stereotype.Service;

@Service
public class ContactMapper {

    public ContactResponseDto toContactResponse(final Contact contact) {
        if (contact == null) {
            return null;
        }
        final ContactResponseDto dto = new ContactResponseDto();
        dto.setId(contact.getId());
        dto.setShopId(contact.getShop() != null ? contact.getShop().getId() : null);
        return dto;
    }

    public Contact toContact(final ContactCreateRequest request) {
        final Contact contact = new Contact();
        if (request.getShopId() != null) {
            final Shop shop = new Shop();
            shop.setId(request.getShopId());
            contact.setShop(shop);
        }
        return contact;
    }

    public Contact toContact(final ContactUpdateRequest request) {
        final Contact contact = new Contact();
        if (request.getShopId() != null) {
            final Shop shop = new Shop();
            shop.setId(request.getShopId());
            contact.setShop(shop);
        }
        return contact;
    }
}
