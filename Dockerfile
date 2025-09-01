# Dockerfile for JAR (GraalVM-based)
FROM ghcr.io/graalvm/native-image:ol8-java17-22.3.3 AS builder

# Set working directory
WORKDIR /app

# Install necessary tools for Maven wrapper and fix locale
RUN microdnf install gzip tar which findutils && \
    microdnf clean all && \
    export LANG=C.UTF-8 && \
    export LC_ALL=C.UTF-8

# Copy Maven files
COPY pom.xml .
COPY mvnw .
COPY .mvn .mvn

# Copy source code
COPY src src

# Build the application with locale fix
ENV LANG=C.UTF-8
ENV LC_ALL=C.UTF-8
RUN chmod +x ./mvnw && ./mvnw clean package -DskipTests

# Runtime stage
FROM ghcr.io/graalvm/jdk:ol8-java17-22.3.3

# Install curl for health checks
RUN microdnf install curl && microdnf clean all

# Create non-root user
RUN groupadd -r spring && useradd -r -g spring spring

# Set working directory
WORKDIR /app

# Copy the JAR file
COPY --from=builder /app/target/*.jar app.jar

# Change ownership
RUN chown -R spring:spring /app

# Switch to non-root user
USER spring

# Expose port
EXPOSE 8080

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=60s --retries=3 \
    CMD curl -f http://localhost:8080/api/users/health || exit 1

# JVM optimization for containers
ENV JAVA_OPTS="-XX:+UseContainerSupport -XX:MaxRAMPercentage=75.0 -XX:+UseG1GC -XX:+UnlockExperimentalVMOptions -XX:+UseJVMCICompiler"

# Start the application
ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]
