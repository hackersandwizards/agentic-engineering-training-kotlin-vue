# 4. Onion/Hexagonal Architecture

## Status

Accepted

## Context

We need to define the internal architecture of the Finden system that:
- Keeps business logic independent of infrastructure concerns
- Makes the codebase testable and maintainable
- Supports Domain-Driven Design principles
- Allows technology changes without affecting core logic
- Can be validated automatically

Traditional layered architectures often lead to:
- Business logic coupled to frameworks and databases
- Difficulty in testing without full infrastructure
- Unclear dependency directions
- Framework code mixed with domain logic

## Decision

We adopt Onion Architecture (also known as Hexagonal or Ports & Adapters) for the backend codebase structure:

```
de.blume2000.finden/
├── domain/
│   ├── model/        # Entities, value objects, aggregates
│   └── service/      # Domain services
├── application/      # Application services (use cases)
└── adapter/
    ├── active/       # Inbound adapters (REST, Kafka consumers)
    └── passive/      # Outbound adapters (repositories, producers, metrics)
```

**Key principles:**
- Domain layer at the center with no external dependencies
- Application layer orchestrates use cases
- Adapters translate between domain and external systems
- Dependencies point inward (adapters → application → domain)
- Repository interfaces defined in domain, implementations in adapters

We enforce these rules using ArchUnit integration tests that fail the build if violated.

## Consequences

### Positive

- **Testability**: Domain logic testable without infrastructure
- **Independence**: Business logic not coupled to frameworks or databases
- **Flexibility**: Can swap databases, frameworks, or APIs without touching domain
- **Clear boundaries**: Package structure makes architecture visible
- **Enforced compliance**: ArchUnit tests prevent architectural violations
- **DDD support**: Natural fit for Domain-Driven Design patterns
- **Team alignment**: Clear rules about where code belongs

### Negative

- **Complexity**: More layers and files than simple layered architecture
- **Learning curve**: Team members need to understand architectural patterns
- **Mapping overhead**: DTOs required at adapter boundaries (no domain objects in APIs)
- **Initial setup time**: More upfront design work required

### Neutral

- **ArchUnit tests**: Located in `src/integrationTest/kotlin/de/blume2000/finden/architecture/`
- **Naming conventions**:
  - Resources end with `Resource` (REST controllers)
  - DTOs end with `DTO`
  - Repositories end with `Repository`
  - Application services end with `ApplicationService`
- **jMolecules annotations**: `@ValueObject`, `@AggregateRoot` make architecture explicit
- **Adapter separation**: active (inbound) vs passive (outbound) clear in package structure
