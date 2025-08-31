package com.example.native_jpa_servlet.infrastructure.adapter.inbound.web.controller;

import com.example.native_jpa_servlet.domain.model.User;
import com.example.native_jpa_servlet.domain.port.inbound.UserServicePort;
import com.example.native_jpa_servlet.infrastructure.adapter.inbound.web.dto.CreateUserRequest;
import com.example.native_jpa_servlet.infrastructure.adapter.inbound.web.dto.UpdateUserRequest;
import com.example.native_jpa_servlet.infrastructure.adapter.inbound.web.dto.UserResponse;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.stream.Collectors;

/**
 * REST Controller for User management
 * This is the inbound adapter that exposes HTTP endpoints
 */
@RestController
@RequestMapping("/api/users")
public class UserController {
    
    private final UserServicePort userServicePort;
    
    public UserController(UserServicePort userServicePort) {
        this.userServicePort = userServicePort;
    }
    
    /**
     * Create a new user
     */
    @PostMapping
    public ResponseEntity<UserResponse> createUser(@RequestBody CreateUserRequest request) {
        try {
            User user = userServicePort.createUser(request.getName(), request.getEmail());
            return ResponseEntity.status(HttpStatus.CREATED).body(new UserResponse(user));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.badRequest().build();
        }
    }
    
    /**
     * Get user by ID
     */
    @GetMapping("/{id}")
    public ResponseEntity<UserResponse> getUserById(@PathVariable Long id) {
        try {
            User user = userServicePort.findUserById(id);
            return ResponseEntity.ok(new UserResponse(user));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    /**
     * Get user by email
     */
    @GetMapping("/email/{email}")
    public ResponseEntity<UserResponse> getUserByEmail(@PathVariable String email) {
        try {
            User user = userServicePort.findUserByEmail(email);
            return ResponseEntity.ok(new UserResponse(user));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    /**
     * Get all users
     */
    @GetMapping
    public ResponseEntity<List<UserResponse>> getAllUsers() {
        List<User> users = userServicePort.getAllUsers();
        List<UserResponse> responses = users.stream()
                .map(UserResponse::new)
                .collect(Collectors.toList());
        return ResponseEntity.ok(responses);
    }
    
    /**
     * Update user
     */
    @PutMapping("/{id}")
    public ResponseEntity<UserResponse> updateUser(
            @PathVariable Long id,
            @RequestBody UpdateUserRequest request) {
        try {
            User user = userServicePort.updateUser(id, request.getName(), request.getEmail());
            return ResponseEntity.ok(new UserResponse(user));
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    /**
     * Delete user
     */
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> deleteUser(@PathVariable Long id) {
        try {
            userServicePort.deleteUser(id);
            return ResponseEntity.noContent().build();
        } catch (IllegalArgumentException e) {
            return ResponseEntity.notFound().build();
        }
    }
    
    /**
     * Health check endpoint
     */
    @GetMapping("/health")
    public ResponseEntity<String> health() {
        return ResponseEntity.ok("User service is running");
    }
}
