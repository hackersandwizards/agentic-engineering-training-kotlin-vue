# 27. Git Hooks with Husky for Pre-Commit Checks

## Status

Accepted

## Context

Code quality issues often slip into commits:
- Linting errors
- Formatting inconsistencies
- Test failures
- TypeScript errors

Catching issues after commit:
- Wastes CI/CD resources
- Delays feedback
- Creates noisy Git history
- Requires rebase/amend to fix

We need pre-commit validation that:
- Runs linters and formatters
- Prevents committing broken code
- Works consistently across team
- Is easy to set up
- Can be bypassed in emergencies

## Decision

We adopt Husky for Git hooks with pre-commit validation.

**Setup:**
- Husky 8.0.1 for Git hooks management
- Installed via `husky install` after npm install
- Pre-commit hook runs linters

**Pre-commit checks:**
- Frontend linting (ESLint, Stylelint)
- TypeScript type checking
- Prettier formatting (auto-fix)

**Installation:**
```bash
npm ci
husky install
```

**Developer workflow:**
1. Make code changes
2. `git add` files
3. `git commit` triggers pre-commit hook
4. Hook runs linters and formatters
5. Commit succeeds if checks pass, fails otherwise

**Bypass (emergency only):**
```bash
git commit --no-verify
```

## Consequences

### Positive

- **Early feedback**: Errors caught before commit
- **Consistent quality**: All commits pass basic checks
- **Reduced CI failures**: Fewer pipeline failures from linting
- **Automatic fixes**: Prettier auto-formats on commit
- **Team consistency**: Everyone uses same hooks
- **Git history**: Cleaner history with fewer fix commits

### Negative

- **Commit slowdown**: Pre-commit checks add 5-10 seconds
- **Developer friction**: Blocked commits can be frustrating
- **Setup required**: Developers must run `husky install`
- **Bypass temptation**: Easy to skip with --no-verify

### Neutral

- **Version**: Husky 8.0.1
- **Installation**: Part of npm ci workflow
- **Hooks directory**: .husky/ in repository
- **Documentation**: README.md explains setup
- **Frontend focus**: Pre-commit hooks primarily for frontend code
- **Commitlint**: @commitlint/cli for commit message format
