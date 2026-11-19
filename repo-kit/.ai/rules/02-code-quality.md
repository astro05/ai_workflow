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
- **Traceability:** each spec-verifying test carries the tag `<SPEC-ID>-AC-NN` (`$KB/<INDEX>` → *Project paths* → `Test tag`). Names follow the project's existing style.
- **Structure:** Arrange / Act / Assert, one behavior per test.
- **Determinism:** no real network, wall clock, or randomness. Inject them through ports / interfaces.
- **Levels:** unit tests for `domain` and `core`; integration tests for `data` adapters against real or containerized dependencies; end-to-end only for critical flows listed in the spec.
- **Coverage target:** every AC, invariant, error code, and edge case in spec §4 and §5 is tested. Line coverage is a smell detector, not the goal.
- Fix flaky tests or delete them through the spec loop. Never retry them until they pass.

## Style
- The formatter and linter are law. Run them on touched files before committing.
- Small functions, intention-revealing names, no dead code, no commented-out code.
- Comments explain *why*, never *what*.
- Only add a dependency when the spec's §2.4 records it (or `.ai/project/` already fixes it).

## Definition of Done
- [ ] Failing test was written first and now passes
- [ ] Build, test suite, lint / type-check (commands: `.ai/project/commands.md`) and `bash .ai/scripts/validate-specs.sh` pass
- [ ] Spec Verification Matrix, `changelog.md` (with files touched), `$KB/<INDEX>`, plan §5 and `$KB/MODULE-MAP.md` are updated
- [ ] No new TODOs without a linked spec Open Question
