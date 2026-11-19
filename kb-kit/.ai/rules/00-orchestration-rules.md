# 00 — Orchestration Rules (Invariants)

These rules apply to every session started in the knowledge base. They add to the repos' rules; they never relax them (`.ai/ai.md` §6).
If a rule blocks you, **stop and ask**. Never work around it.

## Invariants

1. **One requirement at a time.** A session works on one `REQ-*` (or one spec, if no requirement exists). Its `MODULE-MAP.md` row is the progress record and is kept current at every phase boundary.
2. **Requirements are input.** Never edit, rename or delete the documents in `<Module>/SRS/`. Only `plan-requirement` (or a repo's `intake-requirement`) may move loose files into an `NNN-slug/` folder (unchanged) and write its `README.md`.
3. **Plan before spec.** No spec is drafted or amended for a requirement until its `<Module>/Planning/NNN-slug/plan.md` is `Approved`. Only a human approves. Questions for the product owner go in plan §6, never answered by assumption.
4. **Spec before code, per layer.** No code in a layer before the specs it needs are `Approved`; a consumer layer also needs every provider spec it consumes `Approved`. Only a human approves.
5. **Provider contract before consumer code.** A consumer layer implements against a provider contract that is `Approved` and implemented (or being implemented in the same delivery and already passing its tests). If the consumer needs an endpoint, field or message the provider spec lacks, go back to that provider's spec phase; never patch around it in the consumer.
6. **The repo's loop is the loop.** Implementing in a repo means following that repo's `.ai/rules/00` developer loop step by step (failing test first, implement, verify, log the change in the spec changelog, plan, index and map), with that repo's personas, skills, conventions and commands. Load them before you start (`.ai/ai.md` §1 step 6).
7. **Stay in your lane per step.** While planning, edit only `<Module>/SRS/NNN-slug/README.md`, `<Module>/Planning/` and `MODULE-MAP.md` (no repo files at all). While doing a step in a layer, edit only `$REPO` and `<Module>/Implementation/<Layer>/` (plus that layer's index, `MODULE-MAP.md` and the plan's §4/§5). Announce each switch of layer to the human.
8. **Commands run in their repo.** `cd` into the repo root before its build, test, lint or `git` commands. Never run a repo's build from this folder.
9. **Green before next phase.** A phase ends only when its checks pass: `bash _kb/scripts/validate-kb.sh` exits 0 for planning and spec phases; for implementation phases, the repo's Definition of Done (its rule 02) as well.
10. **Separate git histories.** KB changes (requirements, plans, specs, map, indexes, memory) are committed in this repo; code in its own repo on the branch the human names (that repo's branch conventions apply). Commit only when the human asks; never push.
11. **Report, don't hide.** If a test, build or validator fails for a reason outside the requirement, report it with the output; don't fix unrelated code and don't weaken checks.
12. **Every code change leaves a trace in Implementation/.** Each change to a repo's code gets a row in the owning spec's `changelog.md` (what changed, files touched, ACs, branch and commit or `uncommitted`) and moves its plan §5 task status. Code no spec owns means a spec is missing: stop and ask.
13. **Learn once.** When a human corrects you or states a general fix, pattern or convention, record it in `.ai/memory/` in the same turn (`.ai/memory/rule-record-fixes-and-conventions.md`).

## Commit messages in this repo

Conventional Commits, scope = the kind of change (`srs`, `plan`, `specs`, `map`, `memory`):
- `docs(srs): file REQ-Billing-002 invoice export`
- `docs(plan): REQ-Billing-002 plan 0.1.0, questions for the product owner`
- `docs(specs): draft SPEC-Billing-003, FE-Billing-002 for REQ-Billing-002`
- `docs(specs): SPEC-Billing-003 0.2.0 verified AC-01..AC-06`
- `docs(map): REQ-Billing-002 done`
- `docs(memory): record <fix or convention>`

Footer `Refs: REQ-<Module>-NNN` on every commit that belongs to a requirement. (Whether requirement IDs may also appear in the **product repos'** commits and PRs is a team choice: record it in `.ai/memory/` if it differs from the repos' rule 03.)

## Absolute bans

| Ban | Do this instead |
|---|---|
| Editing a requirement document | Ask the requester; record questions in the plan's §6 (or the spec's §1.4 once specs exist) |
| Setting a plan to `Approved` | Ask the human |
| Drafting specs before the plan is `Approved` | Stop at the planning gate |
| Setting a spec to `Approved` / `Deprecated` | Ask the human |
| Implementing a layer whose specs (or consumed provider specs) are `Draft` | Stop at the gate and ask for approval |
| Inventing an API on either side of a contract | Spec change through the provider's spec phase |
| Editing `_kb/`, any `.ai/hooks/`, or tool settings (`.claude/settings*.json`, `.claude/hooks/`, …) | Ask the human |
| Pushing, merging, or rewriting history in any repo | A human does it |
