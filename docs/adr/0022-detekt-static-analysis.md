# 22. Detekt for Kotlin Static Analysis

## Status

Accepted

## Context

Kotlin codebases need static analysis to:
- Enforce code style consistency
- Detect code smells and anti-patterns
- Find potential bugs
- Improve code quality
- Provide automated feedback

Manual code reviews catch some issues but:
- Are time-consuming
- May miss subtle problems
- Are inconsistent between reviewers
- Don't provide immediate feedback

We need automated static analysis that:
- Works with Kotlin
- Integrates with Gradle build
- Fails build on violations
- Is configurable
- Provides clear error messages

## Decision

We adopt Detekt 1.23.8 for Kotlin static analysis.

**Configuration:**
- `detekt-config.yml` defines rules and thresholds
- Gradle plugin integration
- Formatting rules via detekt-formatting plugin
- Build fails on violations (maxIssues: 0)
- Console reports for developers
- JVM target: Java 21

**Rule categories:**
- Code smells
- Complexity
- Formatting
- Performance
- Potential bugs
- Style

**Execution:**
- `./gradlew detekt` runs analysis
- Integrated into CI/CD pipeline
- Can be run locally before commit

## Consequences

### Positive

- **Consistent style**: Automated enforcement of code style
- **Early bug detection**: Catches issues before code review
- **Quality metrics**: Complexity and code smell detection
- **Fast feedback**: Developers get immediate feedback
- **CI integration**: Prevents merging problematic code
- **Customizable**: Rules configurable per project needs
- **Kotlin-specific**: Understands Kotlin idioms and patterns

### Negative

- **Build time**: Static analysis adds to build time
- **False positives**: Sometimes flags valid code
- **Configuration maintenance**: Rules need periodic review
- **Learning curve**: Developers need to understand violations

### Neutral

- **Version**: 1.23.8
- **Config file**: detekt-config.yml in project root
- **Plugins**: detekt-formatting for code formatting rules
- **Exclusions**: Test code excluded via excludes configuration
- **Reports**: Console reports enabled, progress listener disabled
- **Gradle task**: Custom configuration in build.gradle.kts
- **JVM target**: Configured to match project JVM target (21)
- **Thresholds**: maxIssues: 0, warningsAsErrors: false
