# 23. Separated Unit and Integration Tests

## Status

Accepted

## Context

Test suites need to balance:
- Fast feedback for unit tests
- Comprehensive integration testing
- CI/CD pipeline efficiency
- Developer productivity

Running all tests together creates problems:
- Slow feedback cycle (integration tests are slow)
- Developers skip tests locally due to time
- CI pipeline bottlenecks
- Difficult to identify which tests are slow

We need a strategy that:
- Separates fast and slow tests
- Allows running only unit tests during development
- Runs all tests in CI
- Makes test categorization clear

## Decision

We implement separate source sets and Gradle tasks for unit and integration tests.

**Structure:**
- Unit tests: `src/test/kotlin/` tagged with `@Tag("unit")`
- Integration tests: `src/integrationTest/kotlin/` tagged with `@Tag("integration")`
- ArchUnit tests: In integration test source set

**Gradle tasks:**
- `./gradlew unitTest` - Fast unit tests only (mocked dependencies)
- `./gradlew integrationTest` - Slow integration tests (Testcontainers, ArchUnit)
- `./gradlew test` - All tests

**Characteristics:**
- Unit tests: No external dependencies, fast (<1s per test)
- Integration tests: Real databases/Kafka, slower (10-30s startup + test time)

**Coverage:**
- JaCoCo aggregates coverage from both test types
- Integration tests finalized by jacocoTestReport

## Consequences

### Positive

- **Fast feedback**: Unit tests run in seconds
- **Developer productivity**: Can run unit tests frequently during development
- **CI efficiency**: Can parallelize unit and integration tests
- **Clear categorization**: Test type obvious from source set
- **Selective execution**: Run only needed tests
- **Build optimization**: Can skip integration tests for documentation changes

### Negative

- **Duplication**: Some setup code duplicated between test types
- **Complexity**: Two source sets and test tasks to maintain
- **Classification**: Must decide which category for each test

### Neutral

- **Tags**: JUnit 5 `@Tag` annotations separate test types
- **Source sets**: Custom integrationTest source set in Gradle
- **Dependencies**: Integration tests include test source set
- **Task configuration**: useJUnitPlatform with includeTags
- **Coverage**: JaCoCo executionData from both test types
- **CI execution**: Both tasks run in GitLab CI
- **Local development**: Developers typically run unitTest only
