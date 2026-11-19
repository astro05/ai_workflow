# Commit Conventions

> Filled by init-project (moved verbatim from an existing CLAUDE.md / AGENTS.md / README when present). Source of truth for this project (`.ai/ai.md` §6).
> Ships with Conventional Commits 1.0.0. Replace or extend it with the team's own rules, and record the branch convention below.

## Branches

<The team's branch naming, e.g. `feature/<work-item>-<slug>`, `fix/…`, `release/…`, and the integration branch (e.g. `main`, `dev`).>

## Commits

All commits follow [Conventional Commits 1.0.0](https://www.conventionalcommits.org/en/v1.0.0/).

### Structure

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Rules

- **Prefix**: every commit starts with a type (a noun such as `feat`, `fix`), an optional scope, an optional `!`, then a colon and a space.
- **Description**: short summary of the change, immediately after `: `.
- **Scope** (optional): a noun in parentheses naming the affected part of the codebase, e.g. `fix(parser):`.
- **Body** (optional): starts one blank line after the description; free-form, may have multiple paragraphs.
- **Footers** (optional): start one blank line after the body. Each is `<token>: <value>` or `<token> #<value>` (git trailer format).
  - Tokens use `-` instead of spaces (e.g. `Reviewed-by`, `Acked-by`, `Refs`). Only exception: `BREAKING CHANGE`.
  - A value may contain spaces and newlines; it ends where the next valid footer token begins.
- **Casing**: types, scopes and tokens are case-insensitive, but use one casing consistently. `BREAKING CHANGE` must always be uppercase.
- **One change type per commit**: if a change fits more than one type, split it into separate commits where possible.

### Types

| Type | Use for | SemVer |
|------|---------|--------|
| `feat` | New feature | MINOR |
| `fix` | Bug fix | PATCH |
| `build`, `chore`, `ci`, `docs`, `style`, `refactor`, `perf`, `test` | Other changes (permitted, no implicit SemVer effect) | — |
| `revert` | Reverting earlier commits; reference the SHAs in a `Refs:` footer | — |

### Breaking Changes (MAJOR)

Mark a breaking change in either or both ways; it can accompany any type:

- `!` right before the colon: `feat!:` or `feat(api)!:`. With `!`, the footer may be omitted and the description explains the break.
- Footer `BREAKING CHANGE: <description>` (uppercase; `BREAKING-CHANGE:` is equivalent).

### Valid Examples

```
feat(lang): add Polish language
```

```
feat(api)!: send an email to the customer when a product is shipped
```

```
fix: prevent racing of requests

Introduce a request id and a reference to latest request. Dismiss
incoming responses other than from latest request.

Reviewed-by: Z
Refs: #123
```

```
revert: let us never again speak of the noodle incident

Refs: 676104e, a215868
```

### Invalid Examples

| Message | Problem |
|---------|---------|
| `add Polish language` | No type prefix |
| `feat:add Polish language` | Missing space after the colon |
| `breaking change: drop support for Node 6` (footer) | `BREAKING CHANGE` footer must be uppercase |
| `Reviewed by: Z` (footer) | Footer tokens use `-` instead of spaces |
