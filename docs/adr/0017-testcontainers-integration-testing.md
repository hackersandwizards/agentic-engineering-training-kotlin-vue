# 17. Testcontainers for Integration Testing

## Status

Accepted

## Context

Integration tests need to verify the application works correctly with real infrastructure:
- MongoDB database operations
- Kafka message consumption
- Repository implementations
- API endpoints with database

Options for integration testing:
- **Mocks**: Fast but don't test real integration
- **Shared test environment**: Slow, flaky, state pollution
- **Embedded databases**: Limited to specific technologies
- **Testcontainers**: Real Docker containers per test

We need integration tests that:
- Use real MongoDB and Kafka
- Run in CI/CD pipeline
- Are isolated (no shared state)
- Are reproducible
- Are reasonably fast

## Decision

We adopt Testcontainers for integration testing.

**Configuration:**
- MongoDB container: `org.testcontainers:mongodb:1.21.3`
- Kafka container: `org.testcontainers:kafka:1.21.3`
- Separate source set: `src/integrationTest/kotlin`
- Tagged with `@Tag("integration")`
- Quarkus test support: `@QuarkusTest` with Testcontainers
- Gradle task: `./gradlew integrationTest`

**Test structure:**
- Unit tests: Fast, mocked dependencies, `@Tag("unit")`
- Integration tests: Real containers, end-to-end, `@Tag("integration")`
- Architecture tests: ArchUnit, in integration test source set

## Consequences

### Positive

- **Real integration**: Tests use actual MongoDB and Kafka, not mocks
- **Isolation**: Each test class gets fresh containers
- **Reproducibility**: Same containers locally and in CI
- **No setup required**: Containers started automatically
- **Version control**: Container versions match production
- **CI/CD friendly**: Works in any environment with Docker
- **Cleanup**: Containers automatically removed after tests

### Negative

- **Requires Docker**: Cannot run without Docker daemon
- **Slower than mocks**: Container startup adds 10-30 seconds
- **Resource usage**: Containers require CPU and memory
- **CI environment**: CI runners need Docker support
- **Flakiness**: Network issues can cause occasional failures

### Neutral

- **Separate source set**: integrationTest keeps tests organized
- **Gradle tasks**: `unitTest` (fast) and `integrationTest` (slow)
- **Tag-based**: JUnit tags separate test types
- **Quarkus integration**: Quarkus automatically uses Testcontainers
- **Test database**: finden-test database name
- **Coverage**: JaCoCo coverage from both unit and integration tests
- **MongoDB version**: mongo:4.4 container matches production
- **Kafka version**: wurstmeister/kafka matches local docker-compose
