# 9. Kubernetes on GCP Deployment

## Status

Accepted

## Context

Finden requires a production deployment strategy that provides:
- Scalability to handle varying traffic
- High availability and reliability
- Easy deployment and rollback
- Infrastructure as code
- Integration with company cloud platform
- Monitoring and observability

The company has standardized on Google Cloud Platform (GCP) for infrastructure. We need to decide:
- Container orchestration platform
- Infrastructure provisioning approach
- CI/CD integration
- Environment management (dev, prod)

## Decision

We deploy Finden to Google Kubernetes Engine (GKE) on GCP, managed via Terraform and GitLab CI/CD.

**Infrastructure:**
- Kubernetes for container orchestration
- GKE managed Kubernetes clusters
- Terraform for infrastructure as code
- GitLab CI/CD for automated deployment
- Separate dev and prod environments
- Google Cloud Monitoring for observability

**Deployment artifacts:**
- Backend: Quarkus fat JAR in container
- Frontend SSR: Node.js server in container
- MongoDB Atlas: Managed database service

## Consequences

### Positive

- **Scalability**: Kubernetes horizontal pod autoscaling for traffic spikes
- **Reliability**: Self-healing, rolling updates, health checks
- **Cloud-native**: Leverages GCP managed services (GKE, Stackdriver)
- **Infrastructure as code**: Terraform makes infrastructure reproducible
- **GitOps**: Git commits trigger infrastructure changes
- **Environment parity**: Dev and prod use same Kubernetes configs
- **Monitoring**: Integrated with Google Cloud Operations Suite
- **Resource efficiency**: Containers share resources, fast startup

### Negative

- **Complexity**: Kubernetes has steep learning curve
- **Operational overhead**: Cluster management requires DevOps expertise
- **Cost**: GKE nodes and managed services have ongoing costs
- **Debugging**: Troubleshooting distributed systems is complex
- **Local development**: Docker Compose for local, Kubernetes for production (environment differences)

### Neutral

- **GitLab CI**: `.gitlab-ci.yml` defines deployment pipeline
- **Terraform directories**: `infrastructure/operations/`, `infrastructure/mongo/`
- **Environment variables**: GitLab CI variables for sensitive data
- **Service accounts**: GCP service accounts for deployment authentication
- **Container registry**: GitLab container registry
- **Quarkus container**: Fast JAR packaging for quick startup
- **Health endpoints**: `/q/health` for Kubernetes liveness/readiness probes
- **Metrics endpoint**: `/q/metrics` for Prometheus scraping
- **Network**: GCP VPC with private networking
