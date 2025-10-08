# 12. Repository Pattern with Interface in Domain

## Status

Accepted

## Context

Following Onion Architecture and DDD principles, we need to handle data persistence without coupling the domain layer to database technology.

Requirements:
- Domain layer must not depend on MongoDB or any specific database
- Business logic should work with domain objects, not database entities
- Database technology should be replaceable
- Clear separation between domain and infrastructure

The Repository pattern provides an abstraction for data access, but placement of the interface is critical to dependency direction.

## Decision

We implement the Repository pattern with:
- **Interface in domain layer**: `ProduktRepository`, `VerfügbareFilterwerteRepository`
- **Implementation in passive adapter**: `ProduktMongoRepository`, `VerfügbareFilterwerteMongoRepository`
- **Dependency injection**: Application services depend on interface
- **Domain objects**: Repositories work with domain entities, not database entities
- **Mapping**: Adapter layer maps between domain and MongoDB documents

**Example:**
```kotlin
// Domain layer
interface ProduktRepository {
  fun findByFilter(filter: UserProdukteFilter): Produkte
  fun save(produkt: Produkt)
}

// Adapter layer
@ApplicationScoped
class ProduktMongoRepository : ProduktRepository {
  override fun findByFilter(filter: UserProdukteFilter): Produkte {
    // MongoDB-specific implementation
    // Maps MongoProdukt to Produkt
  }
}
```

## Consequences

### Positive

- **Dependency inversion**: Domain doesn't depend on infrastructure
- **Testability**: Can mock repository interface in unit tests
- **Technology independence**: Can swap MongoDB for another database
- **Clear boundaries**: Repository interface defines domain data needs
- **Domain focus**: Business logic works with domain objects
- **DDD alignment**: Repositories are domain concept

### Negative

- **Mapping overhead**: Must map between domain and database entities
- **Duplication**: Domain entities and database entities are similar but separate
- **Complexity**: More types and mapping code

### Neutral

- **Naming**: Interface and implementation share base name with suffix
- **Location**: Interfaces in `domain.model.produkte`, implementations in `adapter.passive.database`
- **MongoDB entities**: MongoProdukt, MongoKlassifikation, etc. in adapter layer
- **Panache**: Repository implementations extend PanacheMongoRepository or use reactive client
- **Quarkus CDI**: @ApplicationScoped for repository implementations
- **ArchUnit**: RepositoryTest enforces interface in domain, implementation in adapter
