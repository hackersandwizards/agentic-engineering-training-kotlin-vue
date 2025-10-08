# 28. jMolecules for DDD Annotations

## Status

Accepted

## Context

Domain-Driven Design patterns should be visible in code:
- Value Objects vs Entities
- Aggregates and Aggregate Roots
- Repositories
- Domain Services

Traditional approaches:
- Naming conventions only (not enforced)
- Comments (often outdated)
- Documentation separate from code
- No tooling support

We need a way to:
- Make DDD patterns explicit in code
- Enable tooling to validate patterns
- Document design decisions in code
- Support ArchUnit tests

## Decision

We adopt jMolecules DDD annotations to explicitly mark DDD building blocks.

**Annotations used:**
- `@ValueObject` - Immutable value objects (Beschreibung, Preis, etc.)
- `@AggregateRoot` - Aggregate root entities
- `@Repository` - Repository interfaces
- Additional annotations available but not yet used

**Example:**
```kotlin
@ValueObject
data class Beschreibung private constructor(
  private val value: String
) {
  // ...
}
```

**Benefits:**
- ArchUnit tests can validate patterns
- IDEs can provide special tooling
- Documentation lives in code
- Explicit design intent

**Version:** org.jmolecules:jmolecules-ddd:1.10.0

## Consequences

### Positive

- **Explicit patterns**: DDD patterns visible in code
- **Tooling support**: ArchUnit and other tools can use annotations
- **Documentation**: Annotations document design decisions
- **Consistency**: Clear markers for DDD building blocks
- **Validation**: ArchUnit tests verify correct annotation usage
- **Searchability**: Easy to find all value objects, aggregates, etc.
- **Standards-based**: jMolecules is DDD community standard

### Negative

- **Dependency**: Adds runtime dependency (though small)
- **Learning curve**: Team must understand DDD terminology
- **Annotation overhead**: More annotations in code

### Neutral

- **Version**: jMolecules 1.10.0
- **Dependency**: org.jmolecules:jmolecules-ddd
- **Scope**: Runtime dependency for annotations
- **Coverage**: Primarily value objects currently
- **ArchUnit integration**: Tests use annotations for validation
- **Future expansion**: Can add more annotations as patterns used
