# ================================
# Stage 1: Build
# ================================
FROM maven:3.9-eclipse-temurin-17 AS builder

WORKDIR /app

# Copy Maven configuration first
COPY pom.xml .

# Copy frontend
COPY frontend ./frontend

# Copy backend source
COPY src ./src

# Build application
RUN mvn clean package -DskipTests


# ================================
# Stage 2: Runtime
# ================================
FROM eclipse-temurin:17-jre

WORKDIR /app

# Create non-root user
RUN groupadd --system spring && \
    useradd --system --gid spring spring

# Copy generated JAR
COPY --from=builder /app/target/*.jar app.jar

# Change ownership
RUN chown spring:spring app.jar

USER spring

EXPOSE 8080

ENV JAVA_OPTS="-XX:MaxRAMPercentage=75.0 -XX:+UseG1GC"

ENTRYPOINT ["sh", "-c", "java $JAVA_OPTS -jar app.jar"]