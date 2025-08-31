package com.example.native_jpa_servlet.domain.service;

import com.example.native_jpa_servlet.domain.model.User;
import com.example.native_jpa_servlet.domain.port.outbound.UserRepositoryPort;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.extension.ExtendWith;
import org.mockito.Mock;
import org.mockito.junit.jupiter.MockitoExtension;

import java.time.LocalDateTime;
import java.util.Arrays;
import java.util.List;
import java.util.Optional;

import static org.junit.jupiter.api.Assertions.*;
import static org.mockito.ArgumentMatchers.any;
import static org.mockito.ArgumentMatchers.anyLong;
import static org.mockito.Mockito.*;

@ExtendWith(MockitoExtension.class)
class UserServiceTest {

    @Mock
    private UserRepositoryPort userRepositoryPort;

    private UserService userService;

    @BeforeEach
    void setUp() {
        userService = new UserService(userRepositoryPort);
    }

    @Test
    void createUser_ShouldCreateUser_WhenValidInput() {
        // Arrange
        String name = "John Doe";
        String email = "john@example.com";
        User expectedUser = new User(1L, name, email, LocalDateTime.now(), LocalDateTime.now());
        
        when(userRepositoryPort.existsByEmail(email)).thenReturn(false);
        when(userRepositoryPort.save(any(User.class))).thenReturn(expectedUser);

        // Act
        User result = userService.createUser(name, email);

        // Assert
        assertNotNull(result);
        assertEquals(name, result.getName());
        assertEquals(email, result.getEmail());
        verify(userRepositoryPort).existsByEmail(email);
        verify(userRepositoryPort).save(any(User.class));
    }

    @Test
    void createUser_ShouldThrowException_WhenEmailExists() {
        // Arrange
        String name = "John Doe";
        String email = "john@example.com";
        
        when(userRepositoryPort.existsByEmail(email)).thenReturn(true);

        // Act & Assert
        IllegalArgumentException exception = assertThrows(
            IllegalArgumentException.class, 
            () -> userService.createUser(name, email)
        );
        
        assertEquals("User with email 'john@example.com' already exists", exception.getMessage());
        verify(userRepositoryPort).existsByEmail(email);
        verify(userRepositoryPort, never()).save(any(User.class));
    }

    @Test
    void createUser_ShouldThrowException_WhenNameIsEmpty() {
        // Act & Assert
        IllegalArgumentException exception = assertThrows(
            IllegalArgumentException.class, 
            () -> userService.createUser("", "john@example.com")
        );
        
        assertEquals("Name cannot be null or empty", exception.getMessage());
    }

    @Test
    void createUser_ShouldThrowException_WhenEmailIsInvalid() {
        // Act & Assert
        IllegalArgumentException exception = assertThrows(
            IllegalArgumentException.class, 
            () -> userService.createUser("John Doe", "invalid-email")
        );
        
        assertEquals("Invalid email format", exception.getMessage());
    }

    @Test
    void findUserById_ShouldReturnUser_WhenUserExists() {
        // Arrange
        Long userId = 1L;
        User expectedUser = new User(userId, "John Doe", "john@example.com", LocalDateTime.now(), LocalDateTime.now());
        
        when(userRepositoryPort.findById(userId)).thenReturn(Optional.of(expectedUser));

        // Act
        User result = userService.findUserById(userId);

        // Assert
        assertNotNull(result);
        assertEquals(userId, result.getId());
        assertEquals("John Doe", result.getName());
        verify(userRepositoryPort).findById(userId);
    }

    @Test
    void findUserById_ShouldThrowException_WhenUserNotFound() {
        // Arrange
        Long userId = 999L;
        
        when(userRepositoryPort.findById(userId)).thenReturn(Optional.empty());

        // Act & Assert
        IllegalArgumentException exception = assertThrows(
            IllegalArgumentException.class, 
            () -> userService.findUserById(userId)
        );
        
        assertEquals("User with ID '999' not found", exception.getMessage());
        verify(userRepositoryPort).findById(userId);
    }

    @Test
    void getAllUsers_ShouldReturnAllUsers() {
        // Arrange
        List<User> expectedUsers = Arrays.asList(
            new User(1L, "John Doe", "john@example.com", LocalDateTime.now(), LocalDateTime.now()),
            new User(2L, "Jane Smith", "jane@example.com", LocalDateTime.now(), LocalDateTime.now())
        );
        
        when(userRepositoryPort.findAll()).thenReturn(expectedUsers);

        // Act
        List<User> result = userService.getAllUsers();

        // Assert
        assertNotNull(result);
        assertEquals(2, result.size());
        assertEquals("John Doe", result.get(0).getName());
        assertEquals("Jane Smith", result.get(1).getName());
        verify(userRepositoryPort).findAll();
    }

    @Test
    void updateUser_ShouldUpdateUser_WhenValidInput() {
        // Arrange
        Long userId = 1L;
        String newName = "John Updated";
        String newEmail = "john.updated@example.com";
        
        User existingUser = new User(userId, "John Doe", "john@example.com", LocalDateTime.now(), LocalDateTime.now());
        User updatedUser = new User(userId, newName, newEmail, existingUser.getCreatedAt(), LocalDateTime.now());
        
        when(userRepositoryPort.findById(userId)).thenReturn(Optional.of(existingUser));
        when(userRepositoryPort.existsByEmail(newEmail)).thenReturn(false);
        when(userRepositoryPort.save(any(User.class))).thenReturn(updatedUser);

        // Act
        User result = userService.updateUser(userId, newName, newEmail);

        // Assert
        assertNotNull(result);
        assertEquals(newName, result.getName());
        assertEquals(newEmail, result.getEmail());
        verify(userRepositoryPort).findById(userId);
        verify(userRepositoryPort).existsByEmail(newEmail);
        verify(userRepositoryPort).save(any(User.class));
    }

    @Test
    void deleteUser_ShouldDeleteUser_WhenUserExists() {
        // Arrange
        Long userId = 1L;
        
        when(userRepositoryPort.existsById(userId)).thenReturn(true);

        // Act
        userService.deleteUser(userId);

        // Assert
        verify(userRepositoryPort).existsById(userId);
        verify(userRepositoryPort).deleteById(userId);
    }

    @Test
    void deleteUser_ShouldThrowException_WhenUserNotFound() {
        // Arrange
        Long userId = 999L;
        
        when(userRepositoryPort.existsById(userId)).thenReturn(false);

        // Act & Assert
        IllegalArgumentException exception = assertThrows(
            IllegalArgumentException.class, 
            () -> userService.deleteUser(userId)
        );
        
        assertEquals("User with ID '999' not found", exception.getMessage());
        verify(userRepositoryPort).existsById(userId);
        verify(userRepositoryPort, never()).deleteById(anyLong());
    }
}
