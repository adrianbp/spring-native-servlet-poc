package com.example.native_jpa_servlet.infrastructure.adapter.outbound.persistence.repository;

import com.example.native_jpa_servlet.infrastructure.adapter.outbound.persistence.entity.UserJpaEntity;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.Optional;

/**
 * Spring Data JPA repository for User entities
 */
@Repository
public interface UserJpaRepository extends JpaRepository<UserJpaEntity, Long> {
    
    /**
     * Find user by email
     * @param email the user email
     * @return Optional containing the user entity if found
     */
    Optional<UserJpaEntity> findByEmail(String email);
    
    /**
     * Check if user exists by email
     * @param email the user email
     * @return true if exists, false otherwise
     */
    boolean existsByEmail(String email);
}
