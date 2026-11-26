---
name: implement-requirement
description: Take one requirement from <Module>/PRD/ end to end — plan it in <Module>/Planning/, specify it layer by layer in <Module>/Implementation/<Layer>/, then implement it task by task, each task end to end — following each repo's own .ai workflow, with human approval gates, and keep the plan, specs, changelogs, indexes and MODULE-MAP updated as the code lands.
---

# Skill: implement-requirement

**Use when:** a human asks to deliver a requirement ("implement the PRD in Billing/PRD/…", "continue REQ-Billing-002"). Persona: `.ai/agents/delivery-lead.md`. Layers, `$REPO`: `.ai/ai.md` → *Paths*.

**The three stages, per module:**

| Stage | Folder | Who writes | Gate |
|---|---|---|---|
| PRD | `<Module>/PRD/NNN-slug/` | the human (documents); agent adds `README.md` | — |
| Planning | `<Module>/Planning/NNN-slug/plan.md` | agent | human approves the plan |
| Implementation | `<Module>/Implementation/<Layer>/NNN-slug/` (`spec.md` + `changelog.md`) | agent | human approves each spec, then reviews the code |

**Layer order:** the order of `_kb/kb.conf` (providers before consumers). Skip a layer that has no row in plan §4. Specs are drafted and approved **per layer** (phase 2); code is built **per task** (phase 3), each task built end to end through its layers.

**Resuming:** read the requirement's `MODULE-MAP.md` row, its plan (§5 task statuses) and the status of its specs; tell the human which phase, task and layer you will resume at, and continue from there.

**Phase boundaries.** Reset or shrink the context only at a gate, never mid-phase. Keep the session when the next phase builds on this one's reasoning (planning → specs); start fresh between implementation tasks, since the plan, specs and map hold the state; use `.ai/skills/hand-off-session` only when the work moves to another tool, directory or person; otherwise compact with a note naming the next phase. Subagents only explore and review (rule 00, invariant 14).

---

## Phase 1 — Planning

1. Run `.ai/skills/plan-requirement`: it files the requirement, explores every repo and writes the plan (approach, impact, work breakdown, questions for the product owner).
2. **Gate:** the human (with the product owner) answers the questions, names the branch in each repo, and sets the plan's `Status: Approved`. No spec is drafted before that. Don't create or switch branches unless told to.

## Phase 2 — Specs (once per layer, in layer order)

1. Load the layer's workflow: `$REPO/.ai/ai.md` and its reading order.
2. As `$REPO/.ai/agents/spec-architect.md`: for each row of plan §4 in this layer, amend the existing spec (version bump, changelog, `Requirements` row) or run `$REPO/.ai/skills/new-spec` (folder `<Module>/Implementation/<Layer>/NNN-slug/`). Carry the plan's decisions (§3) and answers (§6) into the spec; ground every contract in `$REPO`'s code; use `GLOSSARY.md` terms. Propose the spec's §5 *Test entry points* (the few public entry points its ACs will be tested through, reusing existing ones).
   - **Consumer layer:** its `<Provider> Specs` row links the provider specs from this delivery (or existing ones); every endpoint, field and message comes from their §3. A missing contract sends you back to the provider layer's phase 2.
3. Update the layer's index and the `MODULE-MAP.md` row (links replace planned IDs; Trace status `Specifying`). In the plan, write the real spec IDs into §4 and §5.
4. `bash _kb/scripts/validate-kb.sh` exits 0.
5. **Gate:** present the drafted specs (summary, §3 contracts, the proposed test entry points, open questions, riskiest assumptions). Approving a spec confirms its test entry points. The human sets them to `Approved` (spec metadata **and** index). Wait. When every spec of the requirement is `Approved`, set the map's Trace status to `Approved`.

Spec phases of several layers may run together when no consumer needs a new provider contract.

## Phase 3 — Implementation (once per plan §5 task)

Every spec the requirement needs is `Approved` before this phase starts. A task can start when every task in its **Depends on** is `Done`. Take one such task at a time (sequentially: one session, one working tree per repo), set it `In progress`, and build it layer by layer in `_kb/kb.conf` order.

For each layer the task touches, follow `$REPO/.ai/rules/00-spec-driven-rules.md` → *The developer loop* for that layer's ACs in the task. Announce the switch of layer and load the layer's `.ai/` (`.ai/ai.md` §1 step 6). Run every command from `$REPO`; the commands are in `$REPO/.ai/project/commands.md` and the layer index → *Project paths*.

1. **Read spec** — gate: `Approved`. Consumer part of the task: every provider spec it consumes is `Approved`, and the provider part of this task (or an earlier one) is implemented and green, or the contract is already released.
2. **Red → green, one AC at a time** — at the spec's agreed §5 *Test entry points*: one failing test tagged `<SPEC-ID>-AC-NN` (as `$REPO/.ai/agents/test-engineer.md`), seen failing for the right reason; then the minimum code to pass it (as `$REPO/.ai/agents/core-engineer.md`, following `$REPO/.ai/project/` and the relevant `.ai/memory/` entries); then the next AC. Each test goes into the Verification Matrix as it is written. A spec gap → stop, add an Open Question, ask the human, return to phase 2 for that spec.
3. **Verify** — the repo's Definition of Done (its rule 02: build, full test suite, lint/type-check, security checks), `$REPO/.ai/skills/verify-contract` (consumer: against the provider spec versions), and `$REPO/.ai/skills/review-change` on the layer's diff (refactoring happens here, behind green tests); mark covered ACs `Verified`.
4. **Log the change** (this is the implementation trace; do it for every code change, however small):
   - Spec `changelog.md`: a row with date, version, type `implemented` (or `fix`), what changed **and the files touched**, ACs affected, and Ref = branch and commit (or `uncommitted`).
   - Spec version; the layer's index (Version, Coverage, Last Updated).
   - `MODULE-MAP.md`: Trace status `In progress`; for a provider, note any §3 change the consumer specs must know about.
5. When every layer of the task is green: plan §5 task `Done`. `bash _kb/scripts/validate-kb.sh` exits 0.
6. **Gate (per task):** report to the human: the behaviour now working (demo or test evidence), changed files per repo, test results, review findings and what was done about them, suggested commit message per repo (`$REPO` rule 03, plus `.ai/memory/` rules on commit content), and the KB changes. Commit only if asked. Then take the next ready task (a phase boundary: see above).

## Phase 4 — Close-out

1. Every spec of the requirement: coverage complete? Every plan §5 task `Done` or `Dropped` (with a reason)? Set the `MODULE-MAP.md` Trace status to `Done`, or `Partial` with a note naming what remains (e.g. "AC-07 needs manual test data", "frontend deferred").
2. Run `$REPO/.ai/skills/review-change` once more over the whole branch in each repo (fixed point: the branch's merge-base with the integration branch), and `$REPO/.ai/skills/sync-spec` if the human wants a final drift check.
3. Final report: requirement, plan version, specs and versions, coverage per spec, per-repo changes and suggested commits / PR descriptions (`$REPO` rule 03 → *Pull requests*), KB commit message, open items, and anything recorded in `.ai/memory/`, `GLOSSARY.md` or `_decisions/` this session.
4. Offer a workflow review (`.ai/skills/improve-workflow`), especially when the delivery went sideways.
