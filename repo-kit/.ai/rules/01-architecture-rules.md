# 01 — Architecture Rules

`.ai/project/architecture.md` is authoritative. This file only adds SDD obligations on top of it. Do not restructure existing code unless a spec asks for it.

## Layers (`src/`)

`.ai/project/architecture.md` names this repo's real layers. Map them onto the generic layers below (init-project does this in the baseline spec §2.1). A repo with no layering yet uses these as written.

| Generic layer | Contains | May import | Must not |
|---|---|---|---|
| `domain` | Entities, value objects, pure business rules | nothing outside `domain` (plus the language stdlib) | Do I/O, read clocks or randomness directly, or import a framework |
| `core` | Use cases / application services; **ports** (interfaces) for anything external | `domain` | Import `data` or `interfaces`; know about transport or storage details |
| `data` | **Adapters** that implement core ports: DB, HTTP clients, queues, files, other modules' public APIs | `core` (ports), `domain` | Contain business rules |
| `interfaces` | Entrypoints: HTTP handlers, UI, CLI, jobs; the composition root | `core`, `domain`; `data` **only** in the composition root | Contain business rules; return raw internal errors |

Dependencies always point inward: `interfaces → core → domain`, and `data → core/domain`. A dependency that points outward is a defect.
For a UI layer the same idea holds: components (interfaces) → state / services (core) → models (domain); HTTP clients are adapters (data).

## Module boundaries

- One spec owns one module (per layer). The spec's §2.1 names the paths it owns.
- A module talks to another module only through that module's public API (or messages), as specified in the other module's spec §3 and allowed by `.ai/project/architecture.md` → *Cross-module communication*. Never reach into another module's internals.
- Each call or message that crosses a module boundary is a §3 contract of the producing module's spec.
- A new cross-module dependency must be listed in the spec's `Dependencies` and in `$KB/<INDEX>`.
- **Consumer layers:** the boundary to the provider layer is its §3 contract. Calls go through one service/client per feature, never scattered across components.

## Module design

- **Small surface, rich behaviour.** A module's public surface (types, error codes, invariants, required config) should be much smaller than what it does. A class or service that only forwards calls adds surface without behaviour: fold it into its caller or callee.
- **Test through public entry points.** A spec's §5 *Test entry points* names the few entry points (endpoint, use case, component) its ACs are tested through. If a behaviour can only be tested by reaching inside, the module boundary is in the wrong place: raise it with the human.
- **Abstractions need a second implementation.** Add a port or interface only where something really varies (a real adapter and a test fake count).
- **Inject collaborators, return results**, so behaviour is visible at the test entry point.

## Domain language

Names of modules, types, functions, routes, tests and UI labels use the terms of `$KB/GLOSSARY.md`. A concept with no glossary term is raised with the human, not named ad hoc.

## Safety

- **Validate at trust boundaries.** Parse and validate all external input in `interfaces` (or the adapter in `data`) into typed values before it reaches `core`. Never trust input that has not been validated.
- **Secrets** come from the environment or a secret manager, per `.ai/project/conventions.md` → *Configuration & Secrets*. They never appear in code, specs, tests, logs, or commits.
- **Never log PII or credentials.** Log IDs, not payloads.
- **All external I/O has a timeout** and a defined failure mode (listed in spec §4.2). Follow `.ai/project/` for async I/O.
- **Retried operations must be idempotent** (message handlers, jobs, retries), or the spec must say why they can't be.
- **Least privilege:** every credential, token, and DB role gets the minimum scope it needs.
- **Fail closed:** when an authorization check errors, deny access.
- **UI layers:** never render untrusted HTML without the framework's sanitizer; never store tokens where scripts of other origins can read them.

## Decisions

Any choice that is hard to reverse and not already fixed by `.ai/project/` needs a row in the owning spec's §2.4 Decisions **before** implementation. That covers: frameworks, new packages, new projects, datastores, protocols, message contracts, background jobs, sync vs. async, and caching.
A decision that binds more than this spec and is costly to undo becomes a `Draft` decision record in `$KB/_decisions/`, linked from §2.4. Approved decision records are binding; changing one means a new decision record, raised with the human.
