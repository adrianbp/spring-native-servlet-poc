package com.example.native_jpa_servlet.infrastructure.adapter.inbound.web.dto;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * DTO for User update requests
 */
public class UpdateUserRequest {
    
    private final String name;
    private final String email;
    
    @JsonCreator
    public UpdateUserRequest(
            @JsonProperty("name") String name,
            @JsonProperty("email") String email) {
        this.name = name;
        this.email = email;
    }
    
    public String getName() {
        return name;
    }
    
    public String getEmail() {
        return email;
    }
}
