# 18. ArchUnit for Architecture Testing

## Status

Accepted

## Context

Onion Architecture requires strict adherence to dependency rules:
- Domain layer must not depend on outer layers
- Value objects must be immutable
- Repositories must have interfaces in domain
- DTOs must not leak into domain

Traditional code reviews can miss architectural violations. We need automated enforcement that:
- Runs in CI/CD pipeline
- Fails build on violations
- Documents architectural rules
- Prevents architectural drift

Options:
- **Code reviews only**: Manual, inconsistent, easy to miss
- **Dependency analysis tools**: Limited rule expressiveness
- **ArchUnit**: Expressive architecture testing for JVM

## Decision

We adopt ArchUnit 1.4.1 for automated architecture testing.

**Test structure:**
```
src/integrationTest/kotlin/de/blume2000/finden/architecture/
├── onion/
│   ├── OnionTest.kt              # Main onion architecture test
│   ├── domain/
│   │   ├── DomainTest.kt
│   │   └── model/
│   │       ├── ValueObjectTest.kt
│   │       ├── AggregateRootTest.kt
│   │       └── RepositoryTest.kt
│   ├── application/
│   │   └── ApplicationServiceTest.kt
│   └── adapter/
│       ├── active/
│       │   ├── ResourceTest.kt
│       │   └── ConsumerTest.kt
│       └── passive/
│           ├── RepositoryTest.kt
│           └── ProducerTest.kt
├── DependencyRulesTest.kt
├── GeneralCodingRulesTest.kt
└── DependencyInjectionRulesTest.kt
```

**Key rules:**
- Onion architecture layer dependencies
- Value objects immutability and factory pattern
- Repository interfaces in domain
- No domain objects in DTOs
- Naming conventions enforcement

## Consequences

### Positive

- **Automated enforcement**: Architecture violations fail the build
- **Living documentation**: Tests document architecture rules
- **Consistency**: All developers follow same patterns
- **Refactoring safety**: Architectural changes caught immediately
- **Knowledge transfer**: New team members learn from test failures
- **CI integration**: Runs on every commit
- **Comprehensive**: Checks naming, dependencies, annotations

### Negative

- **Learning curve**: Writing ArchUnit tests requires learning the API
- **Maintenance**: Architecture tests need updates when patterns change
- **Build time**: ArchUnit analyzes all classes, adds to test time
- **False positives**: Sometimes legitimate code violates rules

### Neutral

- **JUnit 5**: ArchUnit tests are JUnit 5 tests
- **Integration tests**: Located in integrationTest source set
- **Annotation**: `@AnalyzeClasses` defines scope
- **Imports**: DoNotIncludeTests, DoNotIncludeArchives
- **Package constants**: Defined in OnionTest companion object
- **Tag**: `@Tag("integration")` for integration test execution
- **Gradle task**: Runs with `./gradlew integrationTest`
