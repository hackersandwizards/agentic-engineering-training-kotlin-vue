# 15. Prometheus Metrics and Google Cloud Monitoring

## Status

Accepted

## Context

Production applications require observability to:
- Track system health and performance
- Alert on anomalies
- Diagnose performance issues
- Capacity planning
- SLA monitoring

We need a metrics system that:
- Integrates with GCP monitoring
- Provides Prometheus-compatible metrics
- Supports custom business metrics
- Has minimal performance overhead
- Works with Kubernetes

## Decision

We implement dual metrics export using Micrometer:
- **Prometheus**: For Kubernetes-native scraping
- **Google Cloud Monitoring (Stackdriver)**: For GCP integration

**Architecture:**
- Micrometer as metrics abstraction layer
- Prometheus registry for `/q/metrics` endpoint
- Stackdriver registry for GCP Cloud Monitoring
- Custom metrics via MetricsProvider
- Request metrics via MetricsFilters
- Metrics augmentation via MetricsAugmentor

**Metrics categories:**
- HTTP request metrics (count, duration, status)
- JVM metrics (memory, threads, GC)
- Database query metrics
- Custom business metrics (products filtered, search counts)

## Consequences

### Positive

- **Kubernetes integration**: Prometheus scraping standard in Kubernetes
- **GCP integration**: Native Cloud Monitoring for dashboards and alerting
- **Flexibility**: Micrometer abstraction allows changing exporters
- **Rich metrics**: Automatic HTTP, JVM, and database metrics
- **Custom metrics**: Easy to add domain-specific metrics
- **Performance**: Efficient metric collection and export
- **Grafana compatible**: Prometheus metrics work with Grafana
- **Alerting**: GCP Cloud Monitoring supports alerting

### Negative

- **Dual export**: Both Prometheus and Stackdriver add overhead
- **Configuration**: Need to configure both exporters
- **Cost**: GCP Cloud Monitoring has usage-based costs
- **Cardinality**: Must be careful with high-cardinality labels

### Neutral

- **Micrometer**: Core metrics abstraction
- **Prometheus endpoint**: `/q/metrics` for scraping
- **Stackdriver config**: StackdriverConfigFactory customizes export
- **Resource type**: generic_node for GCP resource mapping
- **Disabled in dev**: Stackdriver export disabled locally
- **Metrics filters**: MetricsFilters augments HTTP metrics
- **Additional tags**: Team, zone, environment added to all metrics
- **Dashboard**: infrastructure/operations/my-little-dashboard.json
