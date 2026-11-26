# 02 — Code Quality

`.ai/project/conventions.md` and the repo's formatter/linter config are authoritative for style. This file adds SDD obligations.

## Follow the existing pattern
- Before writing code, open the neighbouring files and one similar existing feature. Match their naming, file layout, dependency-injection style, helpers, error handling, test style and comment density.
- Reuse existing services, helpers and base classes instead of writing parallel ones.
- If the existing pattern looks wrong, keep to it and raise the improvement with the human; don't silently switch styles. Patterns the human has approved are recorded in `$KB/.ai/memory/`.

## Typing
- Use the strictest type-checker settings the stack offers (e.g. TS `strict`, C# nullable reference types, mypy/pyright `strict`). Fix type errors in code you touch; never silence them without a comment explaining why.
- No `any` / `dynamic` / untyped escape hatches at a module boundary.
- Types for spec §3 contracts are normative: field names, optionality, and enums match the spec exactly (consumer layers: and the provider spec).
- Model "might be absent" explicitly (`Option`, `T | null`, nullable types). Never use sentinel values (`-1`, empty GUIDs, `""`).

## Error contracts
- Every error that can cross a module boundary or reach a caller has a stable code from spec §4.2.
- Never throw strings or generic errors across a boundary. Never swallow errors: handle them, wrap them with context, or propagate them.
- `interfaces` maps internal errors to the external representation defined in spec §3. Stack traces and internal messages never reach callers or users.
- Expected failures (validation, not-found, conflict) are values, typed errors, or 4xx responses. They are not crashes.

## Testing
- **Framework and location:** as `.ai/project/architecture.md` → *Testing Framework* says. Existing test projects keep their own framework.
- **Traceability:** each spec-verifying test carries the tag `<SPEC-ID>-AC-NN` (`$KB/<INDEX>` → *Project paths* → `Test tag`). Names follow the project's existing style and describe the observable outcome in `$KB/GLOSSARY.md` terms.
- **Entry points:** test only through the spec's agreed §5 *Test entry points*, so tests survive refactoring that keeps behaviour.
- **Loop:** one AC per red → green cycle (rule 00, steps 2–3).
- **Structure:** Arrange / Act / Assert, one behavior per test.
- **Determinism:** no real network, wall clock, or randomness. Inject them through ports / interfaces.
- **Fakes only at the system's edges** (external services, clock, randomness, sometimes storage); the repo's own classes are used for real.
- **Assertions:** check what a caller can observe through the entry point, against an expected value taken from the AC or a worked example, never one computed the same way the code computes it; avoid asserting internal calls or reading the database behind the interface's back.
- **Levels:** unit tests for `domain` and `core`; integration tests for `data` adapters against real or containerized dependencies; end-to-end only for critical flows listed in the spec.
- **Coverage target:** every AC, invariant, error code, and edge case in spec §4 and §5 is tested. Line coverage is a smell detector, not the goal.
- Fix flaky tests or delete them through the spec loop. Never retry them until they pass.

## Review
- Every change goes through `.ai/skills/review-change` before it is reported done; refactoring happens there, with the tests green.
- Breaking a documented standard is a hard finding; a design smell is a judgement call. Recurring mechanical findings become automated-check proposals (`$KB/.ai/skills/improve-workflow`).

## Style
- The formatter and linter are law. Run them on touched files before committing.
- Small functions, intention-revealing names, no dead code, no commented-out code.
- Comments explain *why*, never *what*.
- Only add a dependency when the spec's §2.4 records it (or `.ai/project/` already fixes it).

## Definition of Done
- [ ] Each AC went red → green on its own, at an agreed test entry point, and now passes
- [ ] `.ai/skills/review-change` ran on the diff; findings fixed or reported
- [ ] Build, test suite, lint / type-check (commands: `.ai/project/commands.md`) and `bash .ai/scripts/validate-specs.sh` pass
- [ ] Spec Verification Matrix, `changelog.md` (with files touched), `$KB/<INDEX>`, plan §5 and `$KB/MODULE-MAP.md` are updated
- [ ] No new TODOs without a linked spec Open Question
