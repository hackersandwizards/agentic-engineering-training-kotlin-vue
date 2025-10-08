# 3. Kotlin for Backend Development

## Status

Accepted

## Context

We need to choose a JVM language for backend implementation. The primary options are:
- **Java**: Industry standard, largest ecosystem, verbose syntax
- **Kotlin**: Modern JVM language with concise syntax and null safety
- **Scala**: Functional programming focus, complex type system

The backend team has experience with both Java and Kotlin. We need a language that:
- Improves developer productivity
- Reduces boilerplate code
- Provides strong type safety
- Works seamlessly with Quarkus and the JVM ecosystem
- Is maintainable by future team members

## Decision

We adopt Kotlin 2.2.0 as the primary language for backend development.

Kotlin features that influenced this decision:
- **Null safety**: Compile-time null checks prevent NullPointerExceptions
- **Concise syntax**: Data classes, extension functions, and smart casts reduce boilerplate
- **Interoperability**: Seamless integration with Java libraries and frameworks
- **Immutability support**: Val keyword and immutable collections by default
- **Type inference**: Reduces verbose type declarations while maintaining type safety
- **Coroutines**: Built-in async programming support (though not heavily used currently)

## Consequences

### Positive

- **Developer productivity**: 30-40% less code compared to equivalent Java
- **Null safety**: Entire codebase benefits from compile-time null checking
- **Data classes**: Perfect for DTOs and value objects with automatic equals/hashCode/toString
- **Extension functions**: Utility functions (e.g., `sanitize()`, `slugify()`) feel natural
- **Smart casts**: Reduced type casting boilerplate
- **Domain modeling**: Sealed classes and data classes ideal for DDD value objects
- **Quarkus support**: First-class Kotlin support with dedicated extensions

### Negative

- **Build time**: Kotlin compilation is slower than Java compilation
- **Learning curve**: Team members unfamiliar with Kotlin need training
- **Stack traces**: Can be more complex than Java stack traces
- **IDE requirements**: IntelliJ IDEA strongly recommended (less mature support in other IDEs)

### Neutral

- **Gradle configuration**: build.gradle.kts uses Kotlin DSL for type-safe configuration
- **Kotlin plugins**: allopen and noarg plugins required for frameworks (CDI, JPA, MongoDB)
- **JVM target**: Configured for JVM 21 with specific Kotlin API version 2.2
- **Standard library**: kotlin-stdlib-jdk8 adds JVM-specific extensions
