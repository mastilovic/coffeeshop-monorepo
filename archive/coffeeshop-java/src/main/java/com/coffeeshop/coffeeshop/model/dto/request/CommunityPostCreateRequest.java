package com.coffeeshop.coffeeshop.model.dto.request;

import jakarta.validation.constraints.NotBlank;
import jakarta.validation.constraints.Size;

public class CommunityPostCreateRequest {

    @NotBlank
    @Size(max = 2000)
    private String body;

    public String getBody() {
        return body;
    }

    public void setBody(final String body) {
        this.body = body;
    }
}
