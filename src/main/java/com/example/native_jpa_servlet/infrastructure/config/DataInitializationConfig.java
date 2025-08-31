package com.example.native_jpa_servlet.infrastructure.config;

import com.example.native_jpa_servlet.domain.port.inbound.UserServicePort;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Profile;

/**
 * Configuration for data initialization
 */
@Configuration
public class DataInitializationConfig {
    
    /**
     * Initialize some sample data for development/testing
     */
    @Bean
    @Profile("!test")
    public CommandLineRunner initData(UserServicePort userServicePort) {
        return args -> {
            try {
                userServicePort.createUser("John Doe", "john.doe@example.com");
                userServicePort.createUser("Jane Smith", "jane.smith@example.com");
                userServicePort.createUser("Bob Johnson", "bob.johnson@example.com");
                System.out.println("Sample users created successfully!");
            } catch (Exception e) {
                System.err.println("Error creating sample users: " + e.getMessage());
            }
        };
    }
}
