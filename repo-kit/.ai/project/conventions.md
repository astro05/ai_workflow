# Conventions

> Filled by init-project (moved verbatim from an existing CLAUDE.md / AGENTS.md / README when present). Source of truth for this project (`.ai/ai.md` §6).

## Common Patterns & Conventions

- **Naming**: <files, classes, components, private members, prefixes>
- **Data access**: <repositories, query style, required query tagging or logging>
- **DTOs / models**: <where contract types live; domain types not exposed>
- **Dependency injection**: <constructor vs `inject()`, registration>
- **Error handling**: <how errors are logged and mapped to responses / UI>
- **Async**: <async rules for I/O>
- **UI** (UI layers): <component library, forms, templates, state>

## Configuration & Secrets

- Local development: <where local config and secrets live>
- Deployed: <secret manager>
- Sensitive keys: never hardcoded; never in code, specs, tests, logs or commits.

## Style

- Formatter / linter: <tool and config file>. It is law.
