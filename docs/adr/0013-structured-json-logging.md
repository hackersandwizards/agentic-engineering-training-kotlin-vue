# 13. Structured JSON Logging

## Status

Accepted

## Context

Production applications require effective logging for:
- Debugging issues in production
- Monitoring application health
- Audit trails
- Performance analysis
- Security monitoring

Traditional text-based logging makes parsing and analysis difficult. Modern cloud platforms (GCP) work best with structured logs.

Requirements:
- Machine-readable log format
- Contextual information (service, environment, request ID)
- Integration with Google Cloud Logging
- Performance (minimal overhead)
- Developer-friendly for local development

## Decision

We implement structured JSON logging with environment-specific configuration:

**Production:**
- JSON format via quarkus-logging-json extension
- All logs as structured JSON
- Additional fields: serviceName, environment
- Log aggregation in Google Cloud Logging

**Development:**
- Human-readable console output
- JSON logging disabled for better readability
- Same logging code, different output format

**Logging library:**
- kotlin-logging (mu-kotlin-logging) for Kotlin-friendly API
- JBoss LogManager as logging backend
- Sentry integration for error tracking

## Consequences

### Positive

- **Cloud integration**: JSON logs work seamlessly with GCP Log Explorer
- **Queryability**: Can filter/search by any field
- **Structured data**: Additional context included automatically
- **Performance**: Binary format reduces parsing overhead
- **Consistency**: Same format across all services
- **Metrics correlation**: Logs can be correlated with metrics
- **Error tracking**: Sentry integration for error aggregation

### Negative

- **Local development**: JSON logs are harder to read (disabled in dev)
- **Log size**: JSON is more verbose than plain text
- **Configuration complexity**: Different config for different environments

### Neutral

- **Extension**: quarkiverse-logging-json 3.1.0
- **Kotlin logging**: kotlin-logging-jvm 3.0.5
- **Additional fields**: Configured in application.yml
- **Environment detection**: quarkus.profile determines log format
- **Dev override**: `quarkus.log.json.console.enable: false` in %dev
- **Sentry**: quarkus-logging-sentry for error tracking
- **Log levels**: Configurable per package/class
- **Provider**: JsonLoggingProvider sets up JSON formatting
