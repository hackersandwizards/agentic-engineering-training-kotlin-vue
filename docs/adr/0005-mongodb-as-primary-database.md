# 5. MongoDB as Primary Database

## Status

Accepted

## Context

The Finden system needs a database to persist product data for search and filtering. Key requirements:
- Store product documents with varying attributes (colors, categories, availability)
- Support complex queries for filtering (price ranges, delivery dates, classifications)
- Handle flexible schema for different product types
- Provide good performance for read-heavy workloads
- Scale horizontally if needed

Options considered:
- **PostgreSQL**: ACID compliance, mature, but rigid schema
- **MongoDB**: Document database, flexible schema, good for read-heavy workloads
- **Elasticsearch**: Excellent search, but adds operational complexity as primary store

The product domain has varying attributes per product type, making relational modeling challenging. Search and filtering are the primary operations (read-heavy).

## Decision

We select MongoDB 4.4 as the primary database, accessed via Quarkus MongoDB Panache Kotlin extension.

**Key factors:**
- **Document model**: Natural fit for product data with varying attributes
- **Flexible schema**: Can add new product attributes without migrations
- **Query capabilities**: Aggregation framework supports complex filtering
- **Read performance**: Optimized for the read-heavy product search use case
- **Quarkus integration**: mongodb-panache-kotlin provides repository pattern
- **Cloud deployment**: MongoDB Atlas available on GCP

## Consequences

### Positive

- **Flexible schema**: Easy to add new product attributes or categories
- **Natural modeling**: Products as documents match domain model
- **Query power**: Aggregation pipelines for complex filters (e.g., price ranges, available delivery dates)
- **Performance**: Fast reads for product listing and filtering
- **Panache abstraction**: Repository pattern with minimal boilerplate
- **Cloud-ready**: MongoDB Atlas managed service on GCP

### Negative

- **Eventual consistency**: Replicas have eventual consistency
- **Transaction limitations**: Limited multi-document transaction support (not currently needed)
- **Query complexity**: Aggregation pipelines can become complex
- **Operational knowledge**: Team needs MongoDB expertise
- **No foreign keys**: Application must maintain referential integrity

### Neutral

- **Testcontainers**: Integration tests use Testcontainers with MongoDB image
- **Connection**: `mongodb://localhost:27017` for local dev, Atlas for production
- **Database name**: `finden` for dev, `finden-test` for tests
- **Entity mapping**: Custom MongoEntity classes map between domain and storage
- **Index management**: Requires explicit index creation for query performance
