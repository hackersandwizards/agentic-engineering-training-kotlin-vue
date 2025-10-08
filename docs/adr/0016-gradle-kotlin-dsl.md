# 16. Gradle with Kotlin DSL

## Status

Accepted

## Context

The project requires a build tool that:
- Compiles Kotlin backend code
- Manages dependencies
- Runs tests (unit and integration)
- Generates Avro classes from schemas
- Performs static analysis (Detekt)
- Checks dependencies for vulnerabilities
- Produces deployment artifacts
- Works with Quarkus

Options:
- **Maven**: XML-based, verbose, widely used
- **Gradle with Groovy DSL**: Dynamic, flexible
- **Gradle with Kotlin DSL**: Type-safe, IDE support

Gradle is the recommended build tool for Quarkus. Kotlin DSL provides type safety and better IDE support.

## Decision

We use Gradle 8.x with Kotlin DSL for the build system.

**Build configuration:**
- `build.gradle.kts` in Kotlin DSL
- Quarkus Gradle plugin for framework integration
- Custom tasks for separated unit/integration tests
- Detekt plugin for code quality
- OWASP Dependency Check for security
- Avro plugin for schema code generation
- JaCoCo for code coverage

**Key features:**
- Type-safe build scripts
- IDE autocomplete and refactoring
- Custom source sets for integration tests
- Dependency version management
- Gradle wrapper for version consistency

## Consequences

### Positive

- **Type safety**: Compile-time checking of build scripts
- **IDE support**: Full autocomplete and navigation in build.gradle.kts
- **Refactoring**: Rename refactoring works across build files
- **Kotlin consistency**: Same language for build and application
- **Documentation**: Types serve as documentation
- **Plugin API**: Type-safe plugin configuration
- **Quarkus integration**: Excellent Quarkus Gradle support

### Negative

- **Learning curve**: Kotlin DSL less familiar than Groovy DSL
- **Build time**: Kotlin compilation of build scripts adds time
- **Migration**: Converting Groovy to Kotlin DSL requires work
- **Examples**: Fewer online examples in Kotlin DSL than Groovy

### Neutral

- **Wrapper**: gradlew ensures consistent Gradle version
- **Custom tasks**: `unitTest`, `integrationTest` for separated test execution
- **Source sets**: integrationTest source set for integration tests
- **Plugins**: kotlin-jvm, allopen, noarg, quarkus, detekt, avro
- **Dependency management**: Quarkus BOM for version consistency
- **Repositories**: Maven Central, Confluent for Kafka/Avro
- **JVM target**: Java 21 configured in compilerOptions
