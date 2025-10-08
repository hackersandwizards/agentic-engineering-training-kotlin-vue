# 24. Avro Schema Registry for Event Schemas

## Status

Accepted

## Context

Kafka event integration requires schema management for:
- Product update events from upstream systems
- Schema evolution over time
- Backward/forward compatibility
- Type safety in consumers
- Documentation of event structure

Options for event serialization:
- **JSON**: Human-readable but no schema enforcement
- **Protobuf**: Compact, requires schema, Google ecosystem
- **Avro**: Compact, schema registry, Confluent ecosystem
- **Custom binary**: Maximum control but high maintenance

The company platform uses Confluent Kafka with Avro serialization. We need to:
- Consume events with correct schema
- Handle schema evolution
- Generate type-safe Kotlin classes
- Maintain schema compatibility

## Decision

We adopt Avro with Confluent Schema Registry (hosted on Aiven) for event schema management.

**Implementation:**
- Aiven-hosted Confluent Schema Registry
- Gradle Avro plugin generates Kotlin classes from schemas
- Schema download via `./gradlew downloadSchemas` task
- Schemas stored in Avro registry, versioned
- Code generation at build time

**Workflow:**
1. Schemas defined by producer services
2. Schemas published to Aiven Schema Registry
3. Finden downloads schemas before build
4. Avro plugin generates Kotlin data classes
5. Type-safe event consumption in Kafka consumers

**Authentication:**
- AIVEN_SCHEMA_REGISTRY_USER environment variable
- AIVEN_SCHEMA_REGISTRY_URL environment variable
- AIVEN_SCHEMA_REGISTRY_PASSWORD environment variable

## Consequences

### Positive

- **Type safety**: Generated Kotlin classes prevent type errors
- **Schema evolution**: Registry manages compatibility
- **Documentation**: Schemas document event structure
- **Compatibility checking**: Registry validates schema changes
- **Compact serialization**: Binary Avro format smaller than JSON
- **Version management**: Schema versions tracked in registry
- **Build-time generation**: No runtime schema resolution

### Negative

- **Build dependency**: Must download schemas before build
- **Network dependency**: Schema download requires network access
- **External service**: Depends on Aiven Schema Registry availability
- **Environment setup**: Developers must configure environment variables
- **Credential management**: Schema registry credentials required

### Neutral

- **Registry**: erkunden-finden-backend-produkte-consumer user
- **URL**: https://entscheiden-kafka-cluster-entscheiden-dev-project.aivencloud.com:20609
- **Gradle plugin**: com.github.davidmc24.gradle.plugin.avro:1.9.1
- **Serializer**: io.confluent:kafka-avro-serializer:8.0.0
- **Avro version**: org.apache.avro:avro:1.11.0
- **Download task**: Custom Gradle task downloads schemas
- **Generated code**: Placed in build directory, not version controlled
- **Setup docs**: README.md explains environment variable setup
