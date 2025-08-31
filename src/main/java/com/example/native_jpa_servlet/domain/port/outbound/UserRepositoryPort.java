package com.example.native_jpa_servlet.domain.port.outbound;

import com.example.native_jpa_servlet.domain.model.User;
import java.util.List;
import java.util.Optional;

/**
 * Port interface for User persistence operations (outbound port)
 * This interface defines the contract for data access operations
 * following the hexagonal architecture pattern.
 */
public interface UserRepositoryPort {
    
    /**
     * Save a user to the persistence layer
     * @param user the user to save
     * @return the saved user with generated ID
     */
    User save(User user);
    
    /**
     * Find a user by ID
     * @param id the user ID
     * @return Optional containing the user if found, empty otherwise
     */
    Optional<User> findById(Long id);
    
    /**
     * Find a user by email
     * @param email the user email
     * @return Optional containing the user if found, empty otherwise
     */
    Optional<User> findByEmail(String email);
    
    /**
     * Find all users
     * @return list of all users
     */
    List<User> findAll();
    
    /**
     * Delete a user by ID
     * @param id the user ID to delete
     */
    void deleteById(Long id);
    
    /**
     * Check if a user exists by ID
     * @param id the user ID
     * @return true if exists, false otherwise
     */
    boolean existsById(Long id);
    
    /**
     * Check if a user exists by email
     * @param email the user email
     * @return true if exists, false otherwise
     */
    boolean existsByEmail(String email);
}
