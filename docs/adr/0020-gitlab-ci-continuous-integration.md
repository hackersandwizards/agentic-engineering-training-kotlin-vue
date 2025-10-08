# 20. GitLab CI for Continuous Integration and Deployment

## Status

Accepted

## Context

The project requires automated:
- Code compilation and testing
- Static analysis and security scanning
- Docker image building
- Deployment to dev and production
- Infrastructure provisioning

We need a CI/CD system that:
- Integrates with version control
- Supports multiple environments
- Provides deployment approvals
- Manages secrets securely
- Works with our GCP infrastructure

The company uses GitLab for source control, which includes built-in CI/CD capabilities.

## Decision

We adopt GitLab CI/CD for continuous integration and deployment.

**Pipeline structure:**
- Shared job templates from central toolbox repository
- Environment-specific jobs (dev, prod)
- Terraform deployment for infrastructure
- Gradle builds for backend
- npm builds for frontend
- Docker image builds and registry
- Automated tests (unit, integration, architecture)

**Key jobs:**
- Terraform validation and apply (operations, MongoDB)
- Backend build and test
- Frontend build (client, server, SSR)
- Security scanning (Detekt, OWASP Dependency Check)
- Docker image build and push
- Deployment to GKE

**Configuration:**
- `.gitlab-ci.yml` defines pipeline
- Includes from `blume2000/ecom/toolbox/gitlab-ci-job-templates`
- Environment variables for secrets
- Manual approval gates for production

## Consequences

### Positive

- **Automation**: Every commit triggers build and test
- **Fast feedback**: Developers know quickly if changes break tests
- **Consistent builds**: Same build process for all developers
- **Security scanning**: Automated vulnerability detection
- **Environment parity**: Same pipeline for dev and prod
- **Deployment automation**: Reduces manual deployment errors
- **Audit trail**: Complete history of deployments
- **Shared templates**: Consistency across company projects

### Negative

- **GitLab lock-in**: Pipeline config specific to GitLab
- **Complex configuration**: .gitlab-ci.yml can become complex
- **Runner availability**: Depends on GitLab runner capacity
- **Debugging difficulty**: CI failures harder to debug than local

### Neutral

- **Workflow**: Triggered on push or web (manual)
- **Variables**: GRADLE_OPTS, APPLICATION_NAME, TF_VAR_*
- **Environments**: dev (automatic), prod (manual approval)
- **State management**: Terraform state in GCS buckets
- **Service accounts**: Per-environment GCP credentials
- **Secrets**: GitLab CI/CD variables for sensitive data
- **Templates**: terraform.gitlab-ci.yml, environment.gitlab-ci.yml
- **Rules**: Pipeline rules from shared templates
