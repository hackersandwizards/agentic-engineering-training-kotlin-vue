# 25. HTML Sanitization for Security

## Status

Accepted

## Context

Product data received from external systems includes text fields like:
- Beschreibung (product description)
- Produktname (product name)
- Other user-visible text

These fields may contain:
- Accidental or malicious HTML/JavaScript
- SQL injection attempts
- XSS attack vectors
- Malformed markup

We need to ensure:
- User input cannot execute scripts
- HTML is safe for display
- No XSS vulnerabilities
- No database injection

## Decision

We implement mandatory HTML sanitization for all value objects containing user-visible text.

**Implementation:**
- OWASP Java HTML Sanitizer for HTML cleaning
- `sanitize()` utility function in `de.blume2000.util.SanitizingUtil`
- Unbescape library for HTML entity handling
- Sanitization in value object factory methods

**Pattern:**
```kotlin
fun create(rawValue: String): Beschreibung {
  if (rawValue.isBlank()) throw BeschreibungIstLeerException(...)

  val sanitized = rawValue.sanitize()  // HTML sanitization

  if (sanitized.isBlank()) throw BeschreibungIstLeerException(...)

  return Beschreibung(sanitized)
}
```

**Sanitization rules:**
- Remove all HTML tags and scripts
- Decode HTML entities
- Preserve text content only
- Applied before validation

## Consequences

### Positive

- **XSS prevention**: Malicious scripts cannot execute
- **Consistent security**: All value objects protected
- **OWASP standards**: Industry-standard sanitization library
- **Defense in depth**: Sanitization at domain layer
- **Testable**: Sanitization behavior explicitly tested
- **Clear pattern**: All value objects follow same approach

### Negative

- **Performance overhead**: Sanitization adds processing time
- **Data modification**: Original input not preserved
- **Loss of formatting**: Intentional HTML removed

### Neutral

- **Library**: com.googlecode.owasp-java-html-sanitizer:20240325.1
- **Utility**: de.blume2000.util.SanitizingUtil
- **Unbescape**: org.unbescape:unbescape:1.1.6.RELEASE for entity handling
- **Application point**: Value object factory methods
- **Examples**: Beschreibung, Produktname use sanitization
- **Testing**: Value object tests verify sanitization
