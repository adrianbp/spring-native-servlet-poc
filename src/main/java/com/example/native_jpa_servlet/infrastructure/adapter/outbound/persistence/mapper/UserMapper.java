package com.example.native_jpa_servlet.infrastructure.adapter.outbound.persistence.mapper;

import com.example.native_jpa_servlet.domain.model.User;
import com.example.native_jpa_servlet.infrastructure.adapter.outbound.persistence.entity.UserJpaEntity;
import org.springframework.stereotype.Component;

/**
 * Mapper between Domain User and JPA User Entity
 * This class handles the conversion between domain objects and persistence entities
 */
@Component
public class UserMapper {
    
    /**
     * Convert domain User to JPA entity
     * @param user domain user
     * @return JPA entity
     */
    public UserJpaEntity toEntity(User user) {
        if (user == null) {
            return null;
        }
        
        UserJpaEntity entity = new UserJpaEntity();
        entity.setId(user.getId());
        entity.setName(user.getName());
        entity.setEmail(user.getEmail());
        entity.setCreatedAt(user.getCreatedAt());
        entity.setUpdatedAt(user.getUpdatedAt());
        
        return entity;
    }
    
    /**
     * Convert JPA entity to domain User
     * @param entity JPA entity
     * @return domain user
     */
    public User toDomain(UserJpaEntity entity) {
        if (entity == null) {
            return null;
        }
        
        return new User(
            entity.getId(),
            entity.getName(),
            entity.getEmail(),
            entity.getCreatedAt(),
            entity.getUpdatedAt()
        );
    }
}
