# 1. Self-Contained System Architecture

## Status

Accepted

## Context

The Finden product search and filtering system needs to be developed as part of a larger e-commerce platform. We need to decide on the overall architectural approach that balances autonomy, maintainability, and integration capabilities.

Modern e-commerce systems often face challenges with:
- Monolithic architectures that become difficult to maintain and deploy
- Microservices that introduce excessive operational complexity
- Tight coupling between components that reduces team autonomy
- Shared databases that create bottlenecks and deployment dependencies

We need an architecture that allows the team to work independently while still integrating effectively with other platform components.

## Decision

We adopt a Self-Contained System (SCS) architecture for Finden. The system is:
- A complete, independently deployable application with its own backend and frontend
- Responsible for the entire product search and filtering domain
- Equipped with its own database (MongoDB) for data persistence
- Integrated with other systems via asynchronous messaging (Kafka) and synchronous APIs where necessary
- Capable of operating independently without requiring other systems to function

The SCS approach sits between monolithic and microservice architectures, providing:
- Team autonomy with clear boundaries
- Independent deployment and scaling
- Technology freedom within the bounded context
- Reduced coordination overhead

## Consequences

### Positive

- **Team autonomy**: The team can make technology and deployment decisions independently
- **Independent deployment**: Changes can be deployed without coordinating with other teams
- **Clear boundaries**: The product search domain is well-defined and encapsulated
- **Resilience**: The system can operate even if other platform components are unavailable
- **Technology choice**: Freedom to choose optimal technologies for the domain (Quarkus, Vue 3, MongoDB)

### Negative

- **Data duplication**: Product data must be replicated via Kafka events, leading to eventual consistency
- **Cross-system features**: Features spanning multiple systems require inter-system communication
- **Operational overhead**: Each SCS requires its own infrastructure, monitoring, and deployment pipeline
- **Learning curve**: Developers need to understand distributed system patterns (eventual consistency, messaging)

### Neutral

- **Frontend integration**: SSR with Fastify provides a complete user interface while allowing integration with other frontend components
- **Event-driven communication**: Kafka integration requires robust error handling and event schema management
