---
name: implement-requirement
description: Take one requirement from <Module>/SRS/ end to end — plan it in <Module>/Planning/, specify and then implement it layer by layer in <Module>/Implementation/<Layer>/ — following each repo's own .ai workflow, with human approval gates, and keep the plan, specs, changelogs, indexes and MODULE-MAP updated as the code lands.
---

# Skill: implement-requirement

**Use when:** a human asks to deliver a requirement ("implement the SRS in Billing/SRS/…", "continue REQ-Billing-002"). Persona: `.ai/agents/delivery-lead.md`. Layers, `$REPO`: `.ai/ai.md` → *Paths*.

**The three stages, per module:**

| Stage | Folder | Who writes | Gate |
|---|---|---|---|
| SRS | `<Module>/SRS/NNN-slug/` | the human (documents); agent adds `README.md` | — |
| Planning | `<Module>/Planning/NNN-slug/plan.md` | agent | human approves the plan |
| Implementation | `<Module>/Implementation/<Layer>/NNN-slug/` (`spec.md` + `changelog.md`) | agent | human approves each spec, then reviews the code |

**Layer order:** the order of `_kb/kb.conf` (providers before consumers). Skip a layer that has no row in plan §4.

**Resuming:** read the requirement's `MODULE-MAP.md` row, its plan (§5 task statuses) and the status of its specs; tell the human which phase and layer you will resume at, and continue from there.

---

## Phase 1 — Planning

1. Run `.ai/skills/plan-requirement`: it files the requirement, explores every repo and writes the plan (approach, impact, work breakdown, questions for the product owner).
2. **Gate:** the human (with the product owner) answers the questions, names the branch in each repo, and sets the plan's `Status: Approved`. No spec is drafted before that. Don't create or switch branches unless told to.

## Phase 2 — Specs (once per layer, in layer order)

1. Load the layer's workflow: `$REPO/.ai/ai.md` and its reading order.
2. As `$REPO/.ai/agents/spec-architect.md`: for each row of plan §4 in this layer, amend the existing spec (version bump, changelog, `Requirements` row) or run `$REPO/.ai/skills/new-spec` (folder `<Module>/Implementation/<Layer>/NNN-slug/`). Carry the plan's decisions (§3) and answers (§6) into the spec; ground every contract in `$REPO`'s code.
   - **Consumer layer:** its `<Provider> Specs` row links the provider specs from this delivery (or existing ones); every endpoint, field and message comes from their §3. A missing contract sends you back to the provider layer's phase 2.
3. Update the layer's index and the `MODULE-MAP.md` row (links replace planned IDs; Trace status `Specifying`). In the plan, write the real spec IDs into §4 and §5.
4. `bash _kb/scripts/validate-kb.sh` exits 0.
5. **Gate:** present the drafted specs (summary, §3 contracts, open questions, riskiest assumptions). The human sets them to `Approved` (spec metadata **and** index). Wait. When every spec of the requirement is `Approved`, set the map's Trace status to `Approved`.

Spec phases of several layers may run together when no consumer needs a new provider contract.

## Phase 3 — Implementation (once per layer, in layer order)

Follow `$REPO/.ai/rules/00-spec-driven-rules.md` → *The developer loop* for each approved spec of the layer, in the order of plan §5 (a spec before the specs that depend on it). Run every command from `$REPO`; the commands are in `$REPO/.ai/project/commands.md` and the layer index → *Project paths*.

1. **Read spec** — gate: `Approved`. Consumer layer: every provider spec it consumes is `Approved` and its code exists (the provider's phase 3 is done, or it is already released).
2. **Failing tests** — as `$REPO/.ai/agents/test-engineer.md`: tests tagged `<SPEC-ID>-AC-NN` the way the index's *Test tag* row says; run them and see them fail for the right reason. Put the test references in the spec's Verification Matrix.
3. **Implement** — as `$REPO/.ai/agents/core-engineer.md`, following `$REPO/.ai/project/` and the relevant `.ai/memory/` entries. A spec gap → stop, add an Open Question, ask the human, return to phase 2 for that spec.
4. **Verify** — the repo's Definition of Done (its rule 02: build, full test suite, lint/type-check, security checks), `$REPO/.ai/skills/verify-contract` (consumer: against the provider spec versions); mark covered ACs `Verified`.
5. **Log the change** (this is the implementation trace; do it for every code change, however small):
   - Spec `changelog.md`: a row with date, version, type `implemented` (or `fix`), what changed **and the files touched**, ACs affected, and Ref = branch and commit (or `uncommitted`).
   - Spec version; the layer's index (Version, Coverage, Last Updated).
   - Plan §5: the task's Status (`In progress` / `Done`).
   - `MODULE-MAP.md`: Trace status `In progress`; for a provider, note any §3 change the consumer specs must know about.
6. `bash _kb/scripts/validate-kb.sh` exits 0.
7. **Gate:** report to the human: changed files in `$REPO`, test results, suggested commit message (`$REPO` rule 03, plus `.ai/memory/` rules on commit content), and the KB changes. Commit only if asked.

## Phase 4 — Close-out

1. Every spec of the requirement: coverage complete? Every plan §5 task `Done` or `Dropped` (with a reason)? Set the `MODULE-MAP.md` Trace status to `Done`, or `Partial` with a note naming what remains (e.g. "AC-07 needs manual test data", "frontend deferred").
2. Run `$REPO/.ai/skills/sync-spec` in each layer if the human wants a final drift check.
3. Final report: requirement, plan version, specs and versions, coverage per spec, per-repo changes and suggested commits/PR descriptions, KB commit message, open items, and anything recorded in `.ai/memory/` this session.
