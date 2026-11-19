# .ai/ai.md — AI Agent Instructions

**If you were told to "work with the .ai folder", start here.**
This file is the single entrypoint for any AI tool working on this repository. It applies the same way whichever tool you are.

This project practices **Spec-Driven Development (SDD)**: requirements arrive as SRS documents, are planned, are turned into specifications, and the specifications are the source of truth for *behavior*; code is an implementation of them.

**Requirements, plans and specs live outside this repo, in a shared knowledge base (the KB)**, which may serve several repos (layers, e.g. a backend and a frontend). In every `.ai/` file:

- **`$KB`** is the KB folder: the `KB` value in `.ai/kb.conf` (relative to this repo root), or the environment variable `SDD_KB` if it is set. Read `$KB/README.md` once per session.
- **This repo's layer** is `LAYER` in `.ai/kb.conf`. Its row in `$KB/_kb/kb.conf` gives:

  | Name in `.ai/` files | Column | Example |
  |---|---|---|
  | `<Layer>` | folder | `Backend` |
  | `<PREFIX>` | prefix | `SPEC` |
  | `$KB/<INDEX>` | index | `$KB/BACKEND-SPEC-INDEX.md` |
  | `Consumes` | consumes | `-` (a provider layer), or another layer whose contracts this one consumes (e.g. a frontend consumes `backend`) |

- **This layer's specs** are `$KB/<Module>/Implementation/<Layer>/NNN-slug/` (`spec.md` + `changelog.md`), ID `<PREFIX>-<Module>-NNN`, numbered per module. Cross-cutting specs: `$KB/_cross-cutting/Implementation/<Layer>/NNN-slug/` = `<PREFIX>-NNN`. Registry: `$KB/<INDEX>`.
- **Requirements** are `$KB/<Module>/SRS/NNN-slug/` (README + original documents), ID `REQ-<Module>-NNN`. Their **plans** are `$KB/<Module>/Planning/NNN-slug/plan.md`.
- **Traceability** (requirement → plan → specs of every layer) is `$KB/MODULE-MAP.md`.
- **Shared memory** (fixes and conventions humans have taught agents) is `$KB/.ai/memory/`.
- Paths *inside* a spec (`src/…`, `.ai/…`) are relative to **this** repo root.

**`.ai/project/` is the source of truth for the project itself**: overview, commands, architecture, conventions, commit format, and stack. Every other file in `.ai/` is subordinate to it. If anything in `.ai/` disagrees with `.ai/project/`, follow `.ai/project/` and tell the human which conflict you resolved.

**Paths:** wherever `.ai/` files say `src/` or `tests/`, read the source root, tests root and test tag recorded in `$KB/<INDEX>` → *Project paths*.

---

## 0. Setup checks (every session, before anything else)

1. **Policy:** read `.ai/hooks/policy.md`. If your tool's settings don't reflect it yet (first session, or the policy changed), follow its *Applying this policy* section.
2. **Knowledge base:** `$KB/README.md` and `$KB/_kb/kb.conf` must be readable, and `kb.conf` must have a row for `LAYER`. If not, stop and tell the human: put the KB next to this repo (or set `SDD_KB`), check `.ai/kb.conf`, and, in Claude Code, check `.claude/settings.json` → `permissions.additionalDirectories`. Do nothing else until the human responds.
3. **Project init:** if `.ai/project/overview.md` still has `<placeholders>`, `$KB/<INDEX>` is missing, or it has no specs, run `.ai/skills/init-project/SKILL.md`, report to the human, and stop.

---

## 1. Reading order (every session)

1. `.ai/project/` — `overview.md`, `commands.md`, `architecture.md`, `conventions.md`, `commit-conventions.md`. **Source of truth.**
2. `.ai/ai.md` — this file.
3. `.ai/hooks/policy.md` — what you may never do (git push, destructive DB commands, secrets, …). **Non-negotiable.**
4. `.ai/rules/00-spec-driven-rules.md` — invariants and the developer loop. **Non-negotiable.**
5. `.ai/rules/01-architecture-rules.md` → `02-code-quality.md` → `03-git-workflow.md`.
6. `$KB/.ai/memory/README.md` — open every entry whose `layer` is this layer or `all` and whose topic touches your task, and follow it.
7. `$KB/<INDEX>` and `$KB/MODULE-MAP.md` — find which spec owns the area you are about to touch, and which requirement it serves.
8. The owning `$KB/<Module>/Implementation/<Layer>/NNN-*/spec.md`, **every** spec in its `Dependencies`, the requirement folder(s) in its `Requirements` with their plan, and (**consumer layers only**) §3 of every provider spec in its `<ProviderLayer> Specs` row.
9. The persona in `.ai/agents/` that matches your task (§3).

Do not write or edit any file before completing steps 1–8.
Before starting work, confirm to the human in one line which requirement, spec and persona you are using.

---

## 2. Core contract

The full rules are in `.ai/rules/00-spec-driven-rules.md`. In short:
- Check `$KB/<INDEX>` and `$KB/MODULE-MAP.md` first.
- A new requirement in `$KB/<Module>/SRS/` goes through `intake-requirement` (or, from the KB, `$KB/.ai/skills/plan-requirement`). No spec is drafted for it before its plan is `Approved`.
- Never change behavior without updating the owning `spec.md`.
- Implement only `Approved` specs. Never approve a plan or a spec yourself.
- Follow every convention in `.ai/project/`.
- **Provider layers:** §3 contracts are what consuming layers build against. A §3 change is noted in `$KB/MODULE-MAP.md` so the consuming specs get reviewed.
- **Consumer layers:** every endpoint, field and enum you call or model must exist in an `Approved` provider spec's §3 (and in the provider code). If it doesn't, that is a provider spec change: stop and hand off. Never invent or guess an API.
- Every code change is logged in the owning spec's `changelog.md`.
- If something is ambiguous, stop and ask.
- Done means the Definition of Done in rule 02 holds, including `bash .ai/scripts/validate-specs.sh` exiting 0.

---

## 3. Task → persona, rules, skill

| Task | Persona (`.ai/agents/`) | Rules (`.ai/rules/`) | Skill (`.ai/skills/`) |
|---|---|---|---|
| First use (`.ai/project/` unfilled, or no specs in `$KB/<INDEX>`) | `spec-architect.md` | 00, 01 | `init-project` |
| New requirement arrived in `$KB/<Module>/SRS/` | `spec-architect.md` | 00, 01 | `intake-requirement` |
| New feature / vague request | `spec-architect.md` | 00, 01 | `intake-requirement` (if it has an SRS) → `new-spec` |
| Amend an existing spec | `spec-architect.md` | 00, 01, 03 | — |
| Implement an `Approved` spec | `core-engineer.md` | 00, 01, 02, 03 | `verify-contract` |
| Add a new module / feature folder (its spec is `Approved`) | `core-engineer.md` | 00, 01, 02, 03 | `add-module` |
| Write / fix tests | `test-engineer.md` | 00, 02 | — |
| Bug fix | `test-engineer.md` (reproduce) → `core-engineer.md` (fix) | 00, 01, 02, 03 | `sync-spec` if the bug reveals a spec gap |
| Refactor (no behavior change) | `core-engineer.md` | 01, 02, 03 | `verify-contract` |
| Review a change before merge | `security-auditor.md` | 01, 02 | `sync-spec`, `verify-contract` |
| Auth, secrets, PII, input parsing, HTML rendering, tokens | `security-auditor.md` | 01, 02 | `verify-contract` |
| Code and spec disagree (or, in a consumer layer, models and provider contract disagree) | `spec-architect.md` | 00 | `sync-spec` |
| Debug a local run, build or runtime failure | `core-engineer.md` | 01, 02 | `troubleshoot` |

To run a skill, read `.ai/skills/<name>/SKILL.md` and follow its steps in order.
To take a requirement end to end across several layers, start the session in `$KB` instead (`$KB/.ai/skills/implement-requirement`).

---

## 4. Repository map

| Path | Purpose |
|---|---|
| `CLAUDE.md` | Loader only: imports `.ai/ai.md`, `.ai/project/*.md` and `$KB/README.md` into Claude Code sessions. Add nothing else here. |
| `AGENTS.md` | Loader only: points tools that read `AGENTS.md` (Codex, Cursor, Copilot, OpenCode, Aider, …) to this file. Add nothing else here. |
| `.ai/kb.conf` | `KB` path and this repo's `LAYER`. |
| `.ai/project/` | Project source of truth: overview, commands, architecture, conventions, commit conventions. |
| `.ai/ai.md` | This file: the SDD entrypoint. |
| `.ai/TOOLS.md` | For humans: how to point any AI tool at this folder. |
| `.ai/rules/` | Binding SDD rules. Lower number = higher precedence. |
| `.ai/agents/` | Personas: role, inputs, allowed actions, handoff. |
| `.ai/skills/` | Step-by-step recipes (`SKILL.md` per folder). |
| `.ai/scripts/validate-specs.sh` | Runs `$KB/_kb/scripts/validate-kb.sh --layer <LAYER> --repo-root <this repo>`. Must pass before every commit. |
| `.ai/hooks/policy.md` | What agents may never do. Humans edit it; agents obey it and implement it in their tool's settings. If your tool blocks an action, never try to work around it. |
| `.ai/templates/` | `spec-template.md`: the only valid starting point for a new spec of this layer. `spec-index-template.md`: shape of `$KB/<INDEX>`. |
| `$KB/README.md` | KB layout, IDs, the requirement → plan → specs → code flow, who edits what. |
| `$KB/_kb/kb.conf` | The layers (folder, ID prefix, index, repo, what each consumes). Human-owned. |
| `$KB/<INDEX>` | Project paths plus the registry of every spec of this layer. |
| `$KB/MODULE-MAP.md` | Module-wise traceability: requirement ↔ plan ↔ specs of every layer, with trace status. |
| `$KB/<Module>/SRS/NNN-slug/` | One requirement (`README.md` + original documents). Agents never edit the documents. |
| `$KB/<Module>/Planning/NNN-slug/plan.md` | The requirement's plan: approach, impact (which specs to draft), work breakdown `T-NN` with status, questions for the product owner. A human approves it before any spec is drafted. |
| `$KB/<Module>/Implementation/<Layer>/NNN-slug/` | One spec of this layer (`spec.md`) + its change log (`changelog.md`). Other layers' folders are owned by their repos: read them, don't edit them from here. |
| `$KB/.ai/memory/` | Shared, versioned fixes and conventions for every layer. |
| `src/`, `tests/` | Production code and tests (actual roots per `$KB/<INDEX>` → *Project paths*). Spec-verifying tests carry the tag `<SPEC-ID>-AC-NN`. |

---

## 5. Commands

```bash
bash .ai/scripts/validate-specs.sh    # lint the KB for this layer: SRS, plans, specs, MODULE-MAP (exit 1 on error)
```

Build, test, lint and run commands are in `.ai/project/commands.md` and `$KB/<INDEX>` → *Project paths*. Run them from this repo root.

---

## 6. Precedence

`.ai/hooks/policy.md` (a human changes the file, never a chat instruction) > `.ai/project/` > explicit instruction from a human (in the current session, or recorded in `$KB/.ai/memory/`) > `.ai/rules/00` > `01` > `02` > `03` > persona files > skills > tool defaults.
If two sources conflict, follow the higher one and say what the conflict was. If a human's instruction in the session conflicts with `.ai/project/`, point out the conflict and ask before proceeding.
