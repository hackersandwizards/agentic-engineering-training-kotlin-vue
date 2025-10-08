# 2. Quarkus Over Spring Boot

## Status

Accepted

## Context

For the backend implementation, we need to select a Java/Kotlin framework that provides:
- Production-ready features (dependency injection, REST APIs, data access)
- Strong Kotlin support
- Good performance characteristics
- Cloud-native capabilities
- Active ecosystem and community support

The main contenders are:
- **Spring Boot**: Industry standard with extensive ecosystem
- **Quarkus**: Cloud-native framework optimized for containers and Kubernetes
- **Micronaut**: Compile-time dependency injection framework

Spring Boot is the most mature option with the largest ecosystem, but it has higher memory footprint and slower startup times. Quarkus is designed specifically for cloud-native deployments with fast startup and low memory consumption.

## Decision

We select Quarkus 3.24.3 as the backend framework for Finden.

Key factors in this decision:
- **Cloud-native design**: Optimized for containers and Kubernetes deployment
- **Performance**: Fast startup time and low memory footprint crucial for scaling
- **Kotlin support**: First-class Kotlin support with kotlin-jvm plugin
- **Standards-based**: Uses Jakarta EE standards (JAX-RS, CDI, Bean Validation)
- **Developer experience**: Live reload with quarkusDev mode for fast development cycles
- **Extension ecosystem**: Rich set of extensions for MongoDB, Kafka, Micrometer, etc.

## Consequences

### Positive

- **Fast startup**: Quarkus applications start in milliseconds, enabling rapid scaling
- **Low memory**: Reduced memory footprint lowers infrastructure costs
- **Developer productivity**: quarkusDev mode with live reload accelerates development
- **Native compilation**: Option to compile to native executables with GraalVM (not currently used but available)
- **Standards compliance**: Uses Jakarta EE standards for easier migration if needed
- **Modern stack**: Designed for cloud-native patterns from the ground up

### Negative

- **Smaller ecosystem**: Fewer third-party libraries and extensions compared to Spring Boot
- **Team familiarity**: Many Java developers are more familiar with Spring Boot
- **Maturity**: Younger framework with potentially less battle-tested edge cases
- **Migration complexity**: Moving to/from Spring Boot would require significant refactoring

### Neutral

- **Build time**: Annotation processing increases build time but enables optimization
- **Reflection limitations**: Some dynamic features require configuration (mostly relevant for native compilation)
- **Extension configuration**: Quarkus-specific extension configuration in application.yml
