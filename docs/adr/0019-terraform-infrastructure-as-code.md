# 19. Terraform for Infrastructure as Code

## Status

Accepted

## Context

Production infrastructure requires:
- Reproducible environments
- Version-controlled configuration
- Automated provisioning
- Environment parity (dev/prod)
- Disaster recovery capability

Manual infrastructure setup via cloud console:
- Is error-prone
- Lacks version control
- Makes disaster recovery difficult
- Creates environment drift
- Is not reviewable

We need Infrastructure as Code that:
- Works with GCP
- Supports multiple environments
- Integrates with GitLab CI/CD
- Provides plan/apply workflow
- Manages state safely

## Decision

We adopt Terraform for infrastructure as code.

**Structure:**
- `infrastructure/operations/`: GCP resources, dashboards, alerting
- `infrastructure/mongo/`: MongoDB Atlas provisioning
- Separate state per environment (dev/prod)
- GitLab CI/CD integration for automated deployment
- GCP Cloud Storage for Terraform state

**Resources managed:**
- GKE clusters and node pools
- Cloud Monitoring dashboards
- MongoDB Atlas clusters and users
- VPC networking and peering
- IAM service accounts

**Workflow:**
1. Code changes in terraform files
2. GitLab CI runs `terraform plan`
3. Review plan output
4. Manual approval for production
5. GitLab CI runs `terraform apply`

## Consequences

### Positive

- **Version control**: Infrastructure changes tracked in Git
- **Reproducibility**: Can recreate environments from code
- **Review process**: Infrastructure changes reviewed like code
- **Documentation**: Terraform files document infrastructure
- **Disaster recovery**: Can rebuild from Terraform state
- **Environment parity**: Same code for dev and prod (different variables)
- **Automation**: GitLab CI automates deployment
- **State management**: Remote state in GCS prevents conflicts

### Negative

- **Learning curve**: Team needs Terraform expertise
- **State complexity**: Remote state requires careful management
- **Breaking changes**: Terraform updates can break configurations
- **Provider limitations**: GCP provider may lag cloud features
- **Manual resources**: Manually created resources cause drift

### Neutral

- **Version**: Terraform 1.0.4 template from shared templates
- **State backend**: GCP Cloud Storage buckets
- **State files**: Separate per environment
- **Variables**: TF_VAR_* environment variables in GitLab CI
- **Templates**: Shared job templates from ecom/toolbox repo
- **Environments**: dev and prod with separate GCP projects
- **Service accounts**: FINDEN_SERVICE_ACCOUNT_KEY_dev/prod
- **Dashboard**: my-little-dashboard.json templated with environment
