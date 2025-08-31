package com.example.native_jpa_servlet.infrastructure.adapter.outbound.persistence;

import com.example.native_jpa_servlet.domain.model.User;
import com.example.native_jpa_servlet.domain.port.outbound.UserRepositoryPort;
import com.example.native_jpa_servlet.infrastructure.adapter.outbound.persistence.entity.UserJpaEntity;
import com.example.native_jpa_servlet.infrastructure.adapter.outbound.persistence.mapper.UserMapper;
import com.example.native_jpa_servlet.infrastructure.adapter.outbound.persistence.repository.UserJpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;
import java.util.stream.Collectors;

/**
 * JPA implementation of UserRepositoryPort
 * This adapter implements the outbound port using JPA/Hibernate
 */
@Repository
public class UserRepositoryAdapter implements UserRepositoryPort {
    
    private final UserJpaRepository userJpaRepository;
    private final UserMapper userMapper;
    
    public UserRepositoryAdapter(UserJpaRepository userJpaRepository, UserMapper userMapper) {
        this.userJpaRepository = userJpaRepository;
        this.userMapper = userMapper;
    }
    
    @Override
    public User save(User user) {
        UserJpaEntity entity = userMapper.toEntity(user);
        UserJpaEntity savedEntity = userJpaRepository.save(entity);
        return userMapper.toDomain(savedEntity);
    }
    
    @Override
    public Optional<User> findById(Long id) {
        return userJpaRepository.findById(id)
                .map(userMapper::toDomain);
    }
    
    @Override
    public Optional<User> findByEmail(String email) {
        return userJpaRepository.findByEmail(email)
                .map(userMapper::toDomain);
    }
    
    @Override
    public List<User> findAll() {
        return userJpaRepository.findAll()
                .stream()
                .map(userMapper::toDomain)
                .collect(Collectors.toList());
    }
    
    @Override
    public void deleteById(Long id) {
        userJpaRepository.deleteById(id);
    }
    
    @Override
    public boolean existsById(Long id) {
        return userJpaRepository.existsById(id);
    }
    
    @Override
    public boolean existsByEmail(String email) {
        return userJpaRepository.existsByEmail(email);
    }
}
