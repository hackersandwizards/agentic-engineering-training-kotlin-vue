# 21. Domain-Driven Design Principles

## Status

Accepted

## Context

The Finden system implements product search and filtering, which is a well-defined business domain with specific rules and terminology.

Software often fails because:
- Business logic scattered throughout code
- Domain concepts not explicitly modeled
- Technical concerns mixed with business logic
- Ubiquitous language not used
- Domain expertise not captured in code

We need an approach that:
- Captures domain knowledge in code
- Makes business rules explicit
- Creates shared language between developers and domain experts
- Keeps domain logic isolated from technical concerns

## Decision

We adopt Domain-Driven Design (DDD) as the guiding principle for the Finden codebase.

**DDD patterns used:**
- **Value Objects**: Beschreibung, Produktname, Preis, Produktnummer
- **Entities**: Produkt with identity
- **Aggregates**: Produkte as collection
- **Repository pattern**: ProduktRepository for persistence abstraction
- **Domain Services**: For operations not belonging to single entity
- **Ubiquitous Language**: German domain terms throughout codebase

**Tactical patterns:**
- Immutable value objects with validation
- Domain exceptions for rule violations
- Factory methods for object creation
- Repository interfaces in domain layer

**Strategic patterns:**
- Bounded context: Finden (product search/filtering)
- Integration via events (Kafka)
- Anti-corruption layer (adapters)

**jMolecules annotations:**
- `@ValueObject` marks value objects
- `@AggregateRoot` marks aggregates
- Makes DDD patterns explicit

## Consequences

### Positive

- **Explicit domain model**: Business concepts clearly modeled in code
- **Shared language**: Developers and business use same terms
- **Encapsulated logic**: Business rules live with domain objects
- **Testable**: Domain logic testable without infrastructure
- **Maintainable**: Changes to business rules localized to domain
- **Documentation**: Code itself documents domain understanding
- **German language**: Domain terms in German match business language

### Negative

- **Learning curve**: Team must understand DDD patterns
- **More types**: More value objects than using primitives
- **Abstraction overhead**: More layers and indirection
- **Discipline required**: Easy to violate DDD principles

### Neutral

- **jMolecules**: Annotations document DDD patterns (org.jmolecules:jmolecules-ddd:1.10.0)
- **Bounded context**: de.blume2000.finden package
- **German names**: Beschreibung, Produkt, Verfügbarkeit, Klassifikation
- **Exceptions**: Domain exceptions named in German
- **ArchUnit**: Enforces DDD patterns automatically
- **Documentation**: CLAUDE.md explains DDD conventions
