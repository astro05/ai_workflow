# .ai/ai.md — AI Agent Instructions (knowledge base)

**If you were told to "work with the .ai folder", start here.**
This file is the single entrypoint for any AI tool started in this **knowledge base (KB)**. It applies the same way whichever tool you are.

The KB is the **delivery workspace**: requirements (SRS) arrive here, and from here an agent drives a requirement end to end: a plan and specs in this KB, code in the product repos, and specs updated as the code lands. It practices **Spec-Driven Development (SDD)** exactly as the repos do; this folder adds only the orchestration on top.

## Paths

| Name | Meaning | Where it is set |
|---|---|---|
| `$KB` | this folder | — (each repo finds it through its `.ai/kb.conf`, env `SDD_KB` overrides) |
| layer | one product repo that writes specs here (default `backend`, `frontend`) | a row of `_kb/kb.conf`: `layer folder prefix index repo consumes` |
| `$REPO[<layer>]` | that layer's repo | column `repo` of `_kb/kb.conf`, relative to `$KB`; env `SDD_REPO_<LAYER>` overrides (e.g. `SDD_REPO_BACKEND`) |
| `$REPO` | the repo of the layer the current step works on | — |
| provider / consumer | a layer whose `consumes` names another layer builds against that layer's §3 contracts (e.g. frontend consumes backend) | column `consumes` |

Layers are processed **in the order of `_kb/kb.conf`** (providers first). The repos' `.ai/` files call this folder `$KB`. Paths inside a spec (`src/…`, `.ai/…`) are relative to **that layer's repo root**.

**Each repo's own `.ai/` is authoritative for work in that repo.** This file never relaxes it. When you touch `$REPO`, you are bound by `$REPO/.ai/` exactly as if you had been started there.

---

## 0. Setup checks (every session, before anything else)

1. **Policy:** read `.ai/hooks/policy.md` (this folder) and, before touching a repo, that repo's `.ai/hooks/policy.md`. Obey the stricter of the two. If your tool's settings don't reflect this folder's policy yet, follow its *Applying this policy* section.
2. **KB init:** if `_kb/kb.conf` still lists layers whose repos don't exist, an index named in it is missing, or `MODULE-MAP.md` has no module rows besides `_cross-cutting`, run `.ai/skills/init-kb`, report to the human, and stop.
3. **Repos:** `$REPO[<layer>]/.ai/ai.md` must be readable for every layer. If one isn't, stop and tell the human: clone it where `_kb/kb.conf` says (or set the env variable), and, in Claude Code, check `.claude/settings.json` → `permissions.additionalDirectories`. You may still do KB-only work (intake, plans, specs) for the layers that are reachable.
4. **Git:** this folder is its own git repo (requirement, plan and spec history). Each product repo has its own git repo and branch conventions. Never mix them: KB changes are committed here, code changes in their repo.

---

## 1. Reading order (every session)

1. `README.md` — KB layout, IDs, the requirement → plan → specs → code flow, who edits what.
2. `.ai/ai.md` — this file.
3. `.ai/hooks/policy.md` and `.ai/rules/00-orchestration-rules.md` — **non-negotiable**.
4. `_kb/kb.conf`, `MODULE-MAP.md` and every spec index it names — what exists, what is in progress.
5. The requirement you are working on: `<Module>/SRS/NNN-slug/` (every document in full) and its plan `<Module>/Planning/NNN-slug/plan.md` if it exists.
6. **Before any step in a layer:** `$REPO/.ai/ai.md` and its full reading order (`$REPO/.ai/project/*`, `$REPO/.ai/hooks/policy.md`, `$REPO/.ai/rules/00`–`03`, the persona). Load a layer's files when you switch to it; re-read its rule 00 each time you switch.
7. `.ai/memory/README.md` — fixes, patterns and conventions humans have taught agents before. Open each entry whose topic and `layer` touch your task, and follow them. When a human gives a new general fix or convention, record it there (`.ai/memory/rule-record-fixes-and-conventions.md`).

Do not write or edit any file before completing steps 1–5 and 7 (and 6 for the layer you touch).
Before starting work, confirm to the human in one line: requirement, phase (§2), layer, spec, and persona.

---

## 2. The delivery flow

Every module folder has three stages:

```
<Module>/
├── SRS/NNN-slug/                       1. requirements and documents, as the human provides them
├── Planning/NNN-slug/plan.md           2. exploration, approach, work breakdown, questions for the product owner
└── Implementation/
    └── <Layer>/NNN-slug/               3. one spec per layer (spec.md) + its code-change log (changelog.md)
```

The whole flow is `.ai/skills/implement-requirement/SKILL.md`. Its phases, each ending in a human gate:

| Phase | Where | Done by following | Gate |
|---|---|---|---|
| 1. Planning | `<Module>/SRS/` → `<Module>/Planning/` | `.ai/skills/plan-requirement` (all layers) | product owner answers the questions; human approves the plan (Status `Approved`) |
| 2. Specs — once per layer, providers first | `<Module>/Implementation/<Layer>/` | `$REPO/.ai/agents/spec-architect.md`, `$REPO/.ai/skills/new-spec` | human approves the layer's specs (Status `Approved`) |
| 3. Implementation — once per layer, providers first | `$REPO` code + KB spec, changelog and plan updates | `$REPO/.ai/rules/00` developer loop, `$REPO` personas and skills | build, tests, lint, validator green; human reviews |
| 4. Close-out | KB | this folder's rule 00 | MODULE-MAP row `Done` or `Partial` with a note |

With the default layers this is: plan → backend specs → frontend specs → backend code → frontend code → close-out.
A layer is skipped only when the plan's impact table (§4) has no row for it. Spec phases of several layers may run together when no consumer needs a new provider contract.

---

## 3. Task → skill, persona

| Task | Follow |
|---|---|
| First session in a new KB / a layer was added to `_kb/kb.conf` | `.ai/skills/init-kb` |
| "Implement this SRS" / take a requirement end to end | `.ai/skills/implement-requirement` (persona `.ai/agents/delivery-lead.md`) |
| A new file appeared in `<Module>/SRS/` / "plan this requirement" | `.ai/skills/plan-requirement` (phase 1) |
| Product owner answered the plan's questions | `.ai/skills/plan-requirement` step 9 |
| Continue a requirement that is part-way | `implement-requirement`, starting at the phase `MODULE-MAP.md` shows |
| Only the specs / only the code of one layer | Phase 2 / 3 of `implement-requirement`, for that layer |
| Check that a requirement, its specs and the code agree | `$REPO/.ai/skills/sync-spec` in each layer, then update `MODULE-MAP.md` |
| Status of all requirements | Read `MODULE-MAP.md`; run `bash _kb/scripts/validate-kb.sh` |
| A human corrects you or states a convention | Record it in `.ai/memory/` (same turn) |

---

## 4. Commands

Run each repo's commands **from that repo's root** (`cd "$REPO" && …`), never from here. They are listed in `$REPO/.ai/project/commands.md` and in the layer's index → *Project paths*.

```bash
bash _kb/scripts/validate-kb.sh                      # whole KB (SRS, plans, every layer, map) — must exit 0
bash _kb/scripts/validate-kb.sh --layer backend      # one layer (what that repo's .ai/scripts/validate-specs.sh runs)
```

---

## 5. Repository map

| Path | Purpose |
|---|---|
| `CLAUDE.md` | Loader only: imports this file and `README.md`. |
| `AGENTS.md` | Loader only: points tools that read `AGENTS.md` (Codex, Cursor, Copilot, OpenCode, Aider, …) to this file. |
| `.ai/ai.md` | This file. |
| `.ai/TOOLS.md` | For humans: how to start a session here. |
| `.ai/rules/00-orchestration-rules.md` | Binding rules for cross-repo delivery. |
| `.ai/agents/delivery-lead.md` | Persona that drives the flow and hands each step to the right repo persona. |
| `.ai/skills/` | `init-kb` (first run), `implement-requirement` (end to end), `plan-requirement` (file + plan, all layers). |
| `.ai/templates/plan-template.md` | Template of `<Module>/Planning/NNN-slug/plan.md`. |
| `.ai/hooks/policy.md` | What agents may never do from this folder (humans edit it). |
| `.ai/memory/` | Learned fixes, patterns and conventions; agents read the index every session and add to it. |
| `.claude/` | Claude Code settings and the policy hook (humans edit). |
| `_kb/` | `kb.conf` (layers), validator, requirement and spec-index templates. Humans own it. |
| `MODULE-MAP.md`, `*-SPEC-INDEX.md` | Traceability map and one spec registry per layer. |
| `<Module>/`, `_cross-cutting/` | The knowledge base itself; see `README.md`. |

---

## 6. Precedence

For work **in a repo** (its code, or its layer's specs): that repo's `.ai/hooks/policy.md` and this folder's `.ai/hooks/policy.md` (the stricter wins) > that repo's `.ai/project/` > explicit instruction from a human (in the session, or recorded in `.ai/memory/`) > that repo's `.ai/rules/00` … `03` > this folder's rule 00 > personas > skills > tool defaults.
For **KB-only** work (requirement filing, plans, map, indexes): this folder's policy > human instruction (in the session, or recorded in `.ai/memory/`) > this folder's rule 00 > the repos' rule 00 > skills.
If two sources conflict, follow the higher one and say what the conflict was.
