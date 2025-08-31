package com.example.native_jpa_servlet.domain.service;

import com.example.native_jpa_servlet.domain.model.User;
import com.example.native_jpa_servlet.domain.port.inbound.UserServicePort;
import com.example.native_jpa_servlet.domain.port.outbound.UserRepositoryPort;
import org.springframework.stereotype.Service;

import java.util.List;

/**
 * Domain service implementation for User management
 * Contains the business logic and orchestrates domain operations
 */
@Service
public class UserService implements UserServicePort {
    
    private final UserRepositoryPort userRepositoryPort;
    
    public UserService(UserRepositoryPort userRepositoryPort) {
        this.userRepositoryPort = userRepositoryPort;
    }
    
    @Override
    public User createUser(String name, String email) {
        // Validate input
        validateUserInput(name, email);
        
        // Check if email already exists
        if (userRepositoryPort.existsByEmail(email)) {
            throw new IllegalArgumentException("User with email '" + email + "' already exists");
        }
        
        // Create and save user
        User user = new User(name, email);
        return userRepositoryPort.save(user);
    }
    
    @Override
    public User findUserById(Long id) {
        if (id == null) {
            throw new IllegalArgumentException("User ID cannot be null");
        }
        
        return userRepositoryPort.findById(id)
                .orElseThrow(() -> new IllegalArgumentException("User with ID '" + id + "' not found"));
    }
    
    @Override
    public User findUserByEmail(String email) {
        if (email == null || email.trim().isEmpty()) {
            throw new IllegalArgumentException("Email cannot be null or empty");
        }
        
        return userRepositoryPort.findByEmail(email)
                .orElseThrow(() -> new IllegalArgumentException("User with email '" + email + "' not found"));
    }
    
    @Override
    public List<User> getAllUsers() {
        return userRepositoryPort.findAll();
    }
    
    @Override
    public User updateUser(Long id, String name, String email) {
        // Validate input
        if (id == null) {
            throw new IllegalArgumentException("User ID cannot be null");
        }
        validateUserInput(name, email);
        
        // Find existing user
        User existingUser = findUserById(id);
        
        // Check if email is being changed and if new email already exists
        if (!existingUser.getEmail().equals(email) && userRepositoryPort.existsByEmail(email)) {
            throw new IllegalArgumentException("User with email '" + email + "' already exists");
        }
        
        // Update user info
        existingUser.updateInfo(name, email);
        
        // Save and return updated user
        return userRepositoryPort.save(existingUser);
    }
    
    @Override
    public void deleteUser(Long id) {
        if (id == null) {
            throw new IllegalArgumentException("User ID cannot be null");
        }
        
        // Verify user exists before deletion
        if (!userRepositoryPort.existsById(id)) {
            throw new IllegalArgumentException("User with ID '" + id + "' not found");
        }
        
        userRepositoryPort.deleteById(id);
    }
    
    /**
     * Validates user input data
     * @param name the user name
     * @param email the user email
     */
    private void validateUserInput(String name, String email) {
        if (name == null || name.trim().isEmpty()) {
            throw new IllegalArgumentException("Name cannot be null or empty");
        }
        
        if (email == null || email.trim().isEmpty()) {
            throw new IllegalArgumentException("Email cannot be null or empty");
        }
        
        // Basic email validation
        if (!email.contains("@") || !email.contains(".")) {
            throw new IllegalArgumentException("Invalid email format");
        }
    }
}
