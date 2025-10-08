# 7. Event-Driven Kafka Integration

## Status

Accepted

## Context

Finden needs product data from other systems (product management, inventory) to provide search functionality. We need to decide how to:
- Receive product updates from upstream systems
- Maintain product data synchronization
- Handle high-volume product change events
- Ensure system decoupling

Options for integration:
- **Synchronous REST APIs**: Simple but creates tight coupling and availability dependencies
- **Polling**: Regular queries to upstream systems, inefficient and delayed
- **Event streaming (Kafka)**: Asynchronous, decoupled, scalable
- **Message queue (RabbitMQ)**: Asynchronous but less suited for event streaming

The platform already uses Kafka for cross-system communication. Product updates are published as events.

## Decision

We adopt Kafka for event-driven integration with Avro schema serialization.

**Architecture:**
- Consume product events from Kafka topics
- Use Avro schemas from Aiven Schema Registry
- Store product data locally in MongoDB
- Process events asynchronously
- Implement deserialization failure handling

**Technology stack:**
- Quarkus Messaging Kafka extension
- Confluent Registry Avro for schema management
- Kafka Avro Serializer 8.0.0
- Custom LoggingDeserializationFailureHandler

## Consequences

### Positive

- **Decoupling**: Finden operates independently of upstream systems
- **Scalability**: Kafka handles high-volume event streams
- **Resilience**: Events persisted in Kafka, can replay if needed
- **Asynchronous**: Non-blocking processing of product updates
- **Schema evolution**: Avro schemas support backward/forward compatibility
- **Local data**: Fast queries against local MongoDB replica
- **Audit trail**: Event log provides history of all product changes

### Negative

- **Eventual consistency**: Product data updates are not immediate
- **Complexity**: Requires understanding of event streaming patterns
- **Schema management**: Must coordinate schema changes with producers
- **Error handling**: Failed message processing needs dead letter queue or retry logic
- **Operational overhead**: Kafka cluster requires monitoring and maintenance
- **Initial sync**: New instances need to consume historical events

### Neutral

- **Schema Registry**: Aiven-hosted Confluent Schema Registry
- **Download task**: `./gradlew downloadSchemas` fetches schemas before build
- **Environment variables**: AIVEN_SCHEMA_REGISTRY_USER, URL, PASSWORD required
- **Consumer group**: erkunden-finden-backend-produkte-consumer
- **Message format**: Avro binary serialization
- **Failure handler**: LoggingDeserializationFailureHandler logs and skips bad messages
- **Local dev**: Kafka container in docker-compose for development
