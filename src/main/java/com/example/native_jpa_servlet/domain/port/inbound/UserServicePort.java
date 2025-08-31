package com.example.native_jpa_servlet.domain.port.inbound;

import com.example.native_jpa_servlet.domain.model.User;
import java.util.List;

/**
 * Port interface for User service operations (inbound port)
 * This interface defines the use cases for User management
 * following the hexagonal architecture pattern.
 */
public interface UserServicePort {
    
    /**
     * Create a new user
     * @param name the user name
     * @param email the user email
     * @return the created user
     * @throws IllegalArgumentException if email already exists
     */
    User createUser(String name, String email);
    
    /**
     * Find a user by ID
     * @param id the user ID
     * @return the user if found
     * @throws IllegalArgumentException if user not found
     */
    User findUserById(Long id);
    
    /**
     * Find a user by email
     * @param email the user email
     * @return the user if found
     * @throws IllegalArgumentException if user not found
     */
    User findUserByEmail(String email);
    
    /**
     * Get all users
     * @return list of all users
     */
    List<User> getAllUsers();
    
    /**
     * Update user information
     * @param id the user ID
     * @param name the new name
     * @param email the new email
     * @return the updated user
     * @throws IllegalArgumentException if user not found or email already exists
     */
    User updateUser(Long id, String name, String email);
    
    /**
     * Delete a user by ID
     * @param id the user ID
     * @throws IllegalArgumentException if user not found
     */
    void deleteUser(Long id);
}
