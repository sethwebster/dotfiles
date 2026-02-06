# Agent Workspace Instructions

**This file contains workspace-specific context and information for AI agents working in this repository.**

## Quick Start

When you start working in this workspace:

1. Read the general guidelines in [AGENTS.md](./AGENTS.md)
2. Read this file for workspace-specific context
3. Check for any active ADRs in `adr/` directory
4. Review recent commits to understand current work

## Workspace Context

### Repository Information

- **Repository**: AI CLI + agent guidelines + docs site
- **Primary Language**: Bash (CLI), JavaScript/TypeScript (installer + landing page)
- **Framework**: Next.js (landing page in `landing-page/`)
- **Package Manager**: npm

### Key Directories

```
.
├── agents/           # Agent definition markdown files
├── bin/              # npm installer script
├── landing-page/     # Next.js documentation site (MDX)
├── migrations/       # CLI migration scripts
├── ai-function.sh    # Shell function that powers `ai` CLI
└── install.sh        # Curl-based installer
```

### Development Commands

```bash
# Install CLI package deps (root)
npm install

# Run landing page dev server
cd landing-page
npm install
npm run dev

# Lint landing page
cd landing-page
npm run lint

# Build landing page
cd landing-page
npm run build
```

## ⚠️ CRITICAL: Migration Requirements

**UNBREACHABLE CONSTRAINT**: When making changes that affect installed agents or configurations, you MUST create a migration before committing/pushing.

### Migration Rules

Every migration MUST implement:
1. **`migration_up()`** - Apply the change (idempotent)
2. **`migration_down()`** - Reverse the change (idempotent)
3. **Idempotence** - Running up/down multiple times has same effect as once

### Migration Workflow

1. Make your changes to the codebase
2. Create migration file: `migrations/XXX_description.sh`
3. Implement `migration_up()` and `migration_down()`
4. Test both directions:
   ```bash
   ai migrate up
   ai migrate down
   ai migrate up
   ```
5. Verify idempotence (run each direction twice)
6. Only then commit and push

### Migration File Template

```bash
#!/bin/bash
# Migration: XXX
# Description: Brief description
# Version: X.Y.Z
# Date: YYYY-MM-DD

migration_up() {
	# Check before acting (idempotent)
	if [ condition ]; then
		# Apply change
	fi
}

migration_down() {
	# Check before acting (idempotent)
	if [ condition ]; then
		# Reverse change
	fi
}
```

### When to Create Migrations

- Renaming installed agents/skills
- Moving configuration files
- Changing file/directory structures users have
- Updating installed agent frontmatter
- Any change that affects user installations

### When NOT to Create Migrations

- Adding new features (users opt-in via `ai install agents`)
- Documentation updates
- Internal refactoring that doesn't affect installations

---

## Project-Specific Guidelines

### Tech Stack

- **Frontend**: Next.js App Router + MDX (`landing-page/`)
- **Backend**: None (CLI + static docs)
- **Database**: None
- **Caching**: None
- **Testing**: No automated test suite in repo; landing page uses ESLint

### Environment Setup

Required environment variables:
- None documented in repo

### Testing Strategy

- Unit tests: None
- Integration tests: None
- E2E tests: None

### Deployment

- **Staging**: Not documented
- **Production**: Not documented (landing page is a standard Next.js app)
- **CI/CD**: Not documented

## Current Work

### Active Features

- None noted in repo

### Known Issues

- None documented

### Upcoming Work

- None documented

## Important Patterns

### CLI Version Sync

Keep versions synchronized across:
- `package.json` version
- `ai-function.sh` `AI_VERSION`
- Git tag `vX.Y.Z` (see `PUBLISHING.md`)

### Migrations For Installed Changes

Any change that affects installed agents/skills or configuration requires a migration in `migrations/` (see `migrations/README.md`). Always implement idempotent `migration_up()` and `migration_down()` and test both directions.

## Troubleshooting

### Common Issues

**Issue**: [Common problem]
**Solution**: [How to fix it]

---

**Note**: Keep this file updated as the project evolves. This is your workspace's living documentation.
