# 11. TypeScript with Strict Mode

## Status

Accepted

## Context

The frontend codebase uses Vue 3 and requires type safety to:
- Catch errors at compile time
- Improve IDE autocomplete and refactoring
- Document component APIs
- Prevent runtime type errors
- Support large codebase maintenance

Options:
- **JavaScript**: No type checking, maximum flexibility
- **TypeScript with loose config**: Gradual typing, easy adoption
- **TypeScript with strict mode**: Maximum type safety, more upfront work

The SSR server is particularly critical as server-side errors affect all users.

## Decision

We adopt TypeScript 4.7.3 with strict mode enabled for all frontend code.

**Configuration:**
- Strict mode enabled in tsconfig.json
- No implicit any
- Strict null checks
- Strict function types
- All frontend components in TypeScript
- SSR server in TypeScript
- Type definitions for all dependencies

**Enforcement:**
- TypeScript compilation required for build
- ESLint with TypeScript parser
- Pre-commit hooks check TypeScript errors

## Consequences

### Positive

- **Early error detection**: Type errors caught at compile time
- **Better IDE support**: Autocomplete, refactoring, navigation
- **Self-documenting**: Types serve as documentation
- **Refactoring confidence**: Types catch breaking changes
- **Null safety**: Strict null checks prevent undefined errors
- **API contracts**: Clear interfaces between components
- **SSR reliability**: Server-side code benefits most from type safety

### Negative

- **Initial overhead**: More time writing type annotations
- **Learning curve**: Team members need TypeScript knowledge
- **Build time**: Type checking adds to compilation time
- **Third-party types**: Some libraries have incomplete type definitions
- **Strictness**: Strict mode requires more type annotations

### Neutral

- **Version**: TypeScript 4.7.3 (not latest, but stable)
- **Compiler**: ts-jest for testing, tsc for SSR server
- **Configuration**: Separate tsconfig for SSR server
- **Vue integration**: Vue 3 has excellent TypeScript support
- **Type checker**: fork-ts-checker-webpack-plugin for parallel type checking
- **ESLint**: @typescript-eslint/parser and plugin for linting
