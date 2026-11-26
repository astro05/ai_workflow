# 00 — Spec-Driven Rules (Invariants)

These rules override every other file in `.ai/`. Only `.ai/hooks/policy.md` and `.ai/project/` rank above them (see `.ai/ai.md` §6).
If a rule blocks you, **stop and ask**. Never work around it.
`$KB`, `<Layer>`, `<PREFIX>`, `<INDEX>` and `Consumes`: `.ai/ai.md` → intro. This layer's specs are `$KB/<Module>/Implementation/<Layer>/NNN-*/`.

## Core invariants

1. **Plan precedes spec.** No spec is drafted or amended for a requirement until its plan `$KB/<Module>/Planning/NNN-slug/plan.md` is `Approved` by a human. Questions for the product owner go in plan §6, never answered by assumption.
2. **Spec precedes code.** No new or changed production behavior under `src/` without an `Approved` spec that describes it.
3. **The spec is the source of truth for behavior.** If code and spec disagree, the code is wrong until the spec is changed through the loop below. (Project conventions and structure come from `.ai/project/`, not from specs.)
4. **Consumer layers only** (`Consumes` ≠ `-`): **the provider spec is the source of truth for the contract.** Endpoints, request and response fields, nullability, enum values and error codes come from §3 of an `Approved` provider spec, linked in this spec's `<ProviderLayer> Specs` row. A missing or wrong contract is a **provider** spec change, handed off to the provider repo; never patched around in this layer.
5. **No silent drift.** Every behavior change lands together with its spec change. The spec change is made in `$KB` in the same piece of work, and the code PR names the spec ID and version it implements.
6. **Traceability.** Every requirement in `$KB/<Module>/PRD/` maps to the specs that implement it in `$KB/MODULE-MAP.md`; every spec links its requirement(s) in its `Requirements` row; every acceptance criterion (AC) maps to at least one test, written at one of the spec's agreed §5 *Test entry points*; every spec-verifying test carries the tag `<SPEC-ID>-AC-NN` (attached as `$KB/<INDEX>` → *Project paths* → `Test tag` says); every code change has a row in the spec's `changelog.md`.
7. **Humans approve.** Agents may draft and propose. Only a human moves a plan to `Approved`, or a spec to `Approved` or `Deprecated`.
8. **Existing code is grandfathered.** Unspecified code may stay as it is. The first change to a module's behavior requires a spec for that module (at least the behavior being changed) before any code edit.
9. **Requirements are input, not output.** Agents never edit the requirement documents in `$KB/<Module>/PRD/`, nor other layers' specs.
10. **One AC at a time.** Code grows in vertical red → green cycles: one failing test, the minimum code to pass it, then the next AC. Tests are never written in bulk ahead of the code.
11. **Subagents read and report.** A subagent (where the tool has them) only explores (read-only) or reviews (`review-change`); it starts with an empty context, and never edits, builds, installs, branches or commits.
12. **Speak the glossary.** Spec text, ACs, test names and code identifiers use the terms of `$KB/GLOSSARY.md`.

---

## The developer loop

Run this loop for **every** change that affects behavior. Do not skip or reorder steps.

```
                                  +---- next AC -----+
                                  v                  |
[0 Intake] -> [1 Read Spec] -> [2 Red: one failing test] -> [3 Green: minimum code] -> [4 Verify + Review] -> [5 Log the change]
                    ^                                                                                              |
                    +------------------------------------ spec gap found at any step -------------------------------+
```

### 0. Intake (only when the change starts from a requirement)
- A new requirement in `$KB/<Module>/PRD/` goes through `.ai/skills/intake-requirement` (or, in a session started in the KB, `$KB/.ai/skills/plan-requirement`). It gets a `REQ-<Module>-NNN` folder, a plan, and a `$KB/MODULE-MAP.md` row. **Gate:** the plan is `Approved`.

### 1. Read Spec
- Open `$KB/<INDEX>` and `$KB/MODULE-MAP.md`. Find the spec that owns the module you will touch.
- Read the whole spec, every spec in its `Dependencies`, its requirement folder(s) and their plan, and (consumer layers) §3 of every spec in `<ProviderLayer> Specs`.
- **Gate:** the spec is `Approved`; in a consumer layer, every provider spec it consumes is `Approved` too, and its code exists (implemented or already released).
  - `Draft` → stop and hand off to `spec-architect` or a human.
  - No owning spec → run `.ai/skills/new-spec`, then stop for approval.
  - The request isn't covered by the spec → amend the spec first (a spec change needs approval), then restart.

Steps 2 and 3 are one **red → green cycle**, repeated per AC in scope (in the order of the plan §5 task, simplest first): one test, one minimal implementation, then the next AC.

### 2. Red: write one failing spec test
- Pick the next AC. Write **one** test for it at the entry point the spec's §5 *Test entry points* assigns it, where `.ai/project/architecture.md` → *Testing Framework* says, named in the project's existing style (and the `$KB/GLOSSARY.md` terms) and tagged `<SPEC-ID>-AC-NN` (e.g. `[TestCategory("SPEC-Billing-002-AC-03")]` in MSTest, `it('[FE-Billing-001-AC-03] …')` in Jasmine, `@pytest.mark.spec("SPEC-Billing-002-AC-03")` in pytest).
- The test goes through the entry point's public interface and asserts observable behaviour against an independent expected value (rule 02 → *Testing*). No agreed test entry point fits the AC → stop and ask; a new test entry point is a spec change.
- Run it (test command for one AC: `.ai/project/commands.md`). It **must fail, and fail for the right reason**: an assertion failure, not a compile, import or setup error.
- Put the test in the spec's Verification Matrix → `Test Reference` column, as `<path relative to this repo root>::<test name or tag>`.

### 3. Green: implement the minimum
- Write the minimum code that makes **this** failing test pass, and nothing for ACs not yet reached (no speculative parameters, hooks or abstractions).
- Put code only where spec §2.1 says, following `.ai/project/architecture.md`, and matching the patterns of the surrounding code and of similar features.
- Use the contracts in spec §3 (and, in a consumer layer, the provider spec §3) **exactly**: names, types, nullability, enum values, error codes.
- Run the test: green. Then go back to step 2 for the next AC; when every AC in scope is green, go on to step 4.
- If you find a gap or ambiguity in a spec: stop, add it to the spec's §1.4 Open Questions (for a contract gap in a consumer layer, also tell the human which provider spec needs amending), and return to step 1. **Never fill the gap with your own guess.**

### 4. Verify and review
- The code checks of the Definition of Done in rule 02: build, the **full** test suite (or what `.ai/project/commands.md` defines as the suite for the touched area) and lint / type-check all pass. (`validate-specs.sh` runs at the end of step 5, once the trace is written.)
- Walk spec §4: every invariant, error mode, and edge case is covered by a passing test.
- Run `.ai/skills/review-change` on the diff (Standards + Spec). **Refactoring happens here**, behind green tests, never inside the red → green cycle; re-run the suite after it. Report findings you did not fix.
- Set the AC rows you covered to `Verified` in the Verification Matrix.

### 5. Log the change
Every code change, however small, leaves a trace in `$KB`:
- `changelog.md` of the spec: a row with date, version, type (`implemented`, `fix`, …), what changed **and the files touched**, ACs affected, and Ref = branch and commit (or `uncommitted`).
- Spec metadata: bump `Version` and `Last Updated` (semver: MAJOR = breaking contract, MINOR = additive, PATCH = clarification or implementation-only).
- `$KB/<INDEX>`: the spec's row (Status, Version, Coverage, Last Updated).
- The requirement's plan §5: move the task's Status (`In progress` / `Done`).
- `$KB/MODULE-MAP.md`: the requirement's row (spec list, Trace status). **Provider layers:** if a §3 contract changed, add a note naming the consuming specs, so their layer reviews them.
- Then `bash .ai/scripts/validate-specs.sh` exits 0. It checks this trace: the index's Status, Version and Coverage match the spec, the spec's Version has a changelog row, and every `Verified` AC's test file carries its tag.

---

## Absolute bans

| Ban | What it means | Do this instead |
|---|---|---|
| **No phantom APIs** | Never call, import, configure, or document a type, function, endpoint, field, config key, env var, or package that you have not verified exists in this repo, its locked dependencies, or (consumer layers) an `Approved` provider spec and the provider code. | Grep or read the code first. If it doesn't exist and is needed, that is a spec change. |
| **No unrecorded architectural decisions** | Adding a dependency, project, layer, datastore, protocol, external service, background job, cache, or cross-module call without a record. | Record it in spec §2.4 Decisions (decision, alternatives, rationale) **before** implementing. Choices already fixed by `.ai/project/` need no re-decision; cite `.ai/project/`. |
| **No undocumented breaking changes** | Changing a §3 contract in a way that breaks existing callers or stored data. | MAJOR version bump, a changelog entry tagged `BREAKING`, migration notes, `!` / `BREAKING CHANGE` in the commit, every dependent spec in `$KB/<INDEX>` reviewed, and every consuming spec of other layers flagged in `$KB/MODULE-MAP.md`. |
| **No self-approval** | An agent setting a plan or spec to `Approved` (or a spec to `Deprecated`). | Hand off to a human. |
| **No test weakening** | Deleting, skipping, or loosening a test, or editing an AC, to make a build green. | Fix the code, or change the spec through the loop with approval. |
| **No batch-first work** | Writing the tests for many ACs before any code, or building a whole layer before any behaviour works end to end. | One AC per red → green cycle (invariant 10); plan §5 tasks work end to end. |
| **No write-capable subagents** | A subagent that edits, builds, branches or commits, or several tasks implemented in parallel. | This session writes, one task at a time; subagents only explore and review (invariant 11). |
| **No orphan code** | New code with no spec, or spec-verifying tests with no AC tag. | Trace it to a spec, or delete it. |
| **No untraced changes** | A spec missing from `$KB/MODULE-MAP.md`, a requirement whose specs are not listed, or a code change with no `changelog.md` row. | Update the map and the changelog in the same change (`validate-specs.sh` enforces the map). |
| **No contract patching** (consumer layers) | Working around a missing or wrong provider contract in this layer. | Hand off a provider spec change. |

---

## When unsure

Stop and ask a specific question. A question costs minutes; drift costs weeks.
