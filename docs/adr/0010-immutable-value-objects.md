# 10. Immutable Value Objects with Factory Methods

## Status

Accepted

## Context

Domain-Driven Design emphasizes value objects for domain concepts without identity. In the Finden domain, we have many such concepts: Beschreibung (description), Produktname, Produktnummer, Preis, etc.

Requirements for value objects:
- Immutability to prevent accidental modification
- Validation of business rules
- Equality based on value, not identity
- Type safety (not just primitive types)
- Clear API for construction

We need a consistent pattern for value objects that:
- Enforces immutability
- Validates invariants at construction
- Provides clear error messages
- Works well with Kotlin

## Decision

We adopt a standardized pattern for all value objects:

**Pattern:**
```kotlin
@ValueObject
data class Beschreibung private constructor(
  private val value: String
) {
  fun asString(): String = value

  companion object {
    private const val MAX_LENGTH = 500

    fun create(rawValue: String): Beschreibung {
      if (rawValue.isBlank()) {
        throw BeschreibungIstLeerException("Beschreibung darf nicht leer sein")
      }

      val sanitized = rawValue.sanitize()

      if (sanitized.length > MAX_LENGTH) {
        throw BeschreibungIstZuLangException("...")
      }

      return Beschreibung(sanitized)
    }
  }
}
```

**Key elements:**
- Private constructor prevents invalid construction
- Factory method `create()` performs validation
- Private field named `value` or semantically appropriate
- Public accessor method `asString()`, `asInt()`, etc.
- Domain exceptions for validation failures
- `data class` for automatic equals/hashCode/toString
- `@ValueObject` annotation from jMolecules

## Consequences

### Positive

- **Immutability**: Constructor is private, no setters
- **Validation**: All invariants checked at creation time
- **Type safety**: Cannot accidentally use String where Beschreibung is expected
- **Clear errors**: Domain exceptions explain what's wrong
- **Testability**: Easy to create test instances via factory
- **Equality**: data class provides value-based equality
- **Documentation**: Pattern is self-documenting
- **DDD alignment**: Matches DDD value object principles

### Negative

- **Verbosity**: More code than using primitives directly
- **Creation overhead**: Factory method adds minimal runtime overhead
- **Exception handling**: Callers must handle domain exceptions

### Neutral

- **Naming convention**: Exceptions named descriptively (e.g., `BeschreibungIstLeerException`)
- **German domain language**: Value objects use German names matching ubiquitous language
- **Sanitization**: Often uses `sanitize()` utility for HTML safety
- **Validation location**: All validation in factory method, not distributed
- **Examples**: Beschreibung, Produktname, Produktnummer, KlassifikationId, Produktfarbe
- **ArchUnit enforcement**: ValueObjectTest ensures pattern compliance
