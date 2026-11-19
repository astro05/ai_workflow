# ai_workflow — Spec-Driven Development kit for AI agents

A tool-neutral workflow that lets AI agents (Claude Code, Codex, Cursor, Copilot, Gemini CLI, OpenCode, Aider, …) take a business requirement from its documents to an approved plan, approved specs and tested code, with human gates in between and a full trace of every change.

It is the generic form of a workflow proven in production: one **knowledge base** repo plus one or more **product repos** (layers, e.g. a backend and a frontend), each with its own `.ai/` folder.

```
<parent>/
├── ProjectKB/      ← kb-kit/     requirements (SRS) → plans → specs per layer, map, memory, validator
├── backend/        ← repo-kit/   code + .ai/ (rules, personas, skills, project docs); specs live in the KB
└── frontend/       ← repo-kit/   same kit, LAYER=frontend; consumes the backend's §3 contracts
```

## The model in one page

| Stage | Where (in the KB) | Who | Gate |
|---|---|---|---|
| 1. SRS | `<Module>/SRS/NNN-slug/` — the documents as received + a `README.md` | human drops files; agent files them | — |
| 2. Planning | `<Module>/Planning/NNN-slug/plan.md` — understanding, findings, approach, impact per layer, work breakdown, questions for the product owner | agent | product owner answers; human sets `Approved` |
| 3. Specs | `<Module>/Implementation/<Layer>/NNN-slug/spec.md` — one per module and layer, providers first | agent, as the repo's `spec-architect` | human sets `Approved` (spec + index) |
| 4. Code | each repo, following its rule 00 developer loop (failing test → implement → verify → log) | agent, as the repo's `test-engineer` / `core-engineer` | build, tests, lint, validator green; human reviews |
| Trace | `changelog.md` next to each spec (every code change, with files and commit), plan §5 task status, `*-SPEC-INDEX.md`, `MODULE-MAP.md` | agent, in the same change | `validate-kb.sh` |

Key rules: plan before spec, spec before code, humans approve, a consumer layer never invents a provider API, requirement documents are read-only, agents never push, and every correction a human gives is recorded once in the KB's `.ai/memory/` so no agent repeats it.

Session entrypoints:
- Started in the **KB**: `.ai/ai.md` → skill `implement-requirement` drives a requirement through every layer (persona `delivery-lead`), switching into each repo's own `.ai/` for its steps.
- Started in a **repo**: `.ai/ai.md` → that layer only (`intake-requirement`, `new-spec`, the developer loop, `verify-contract`, `sync-spec`, …).

## What's in this repo

| Path | Copy to | Contents |
|---|---|---|
| `kb-kit/` | the root of a new KB repo (e.g. `ProjectKB/`) | `README.md`, `CLAUDE.md` + `AGENTS.md` (loaders), `.gitattributes`, `MODULE-MAP.md`, one `*-SPEC-INDEX.md` per layer, `.ai/` (ai.md, TOOLS.md, rule 00 orchestration, `delivery-lead`, skills `init-kb` / `plan-requirement` / `implement-requirement`, plan template, `memory/`), `_kb/` (`kb.conf` layers, `validate-kb.sh`, templates), `_cross-cutting/` |
| `repo-kit/` | the root of each product repo | `CLAUDE.md` + `AGENTS.md` (loaders), `.ai/` (ai.md, TOOLS.md, `kb.conf`, `project/` templates, rules 00–03, 4 personas, 7 skills, spec and index templates, `scripts/validate-specs.sh`) |
| `_staging/` | see below | the files of both kits that live under `.claude/` and `.ai/hooks/` |
| `prompts.md` | — | a one-off prompt template for teams not using the kit |

### `_staging/` (install step)

The policy hook these kits ship protects every `.claude/` settings file and `.ai/hooks/` folder it can see, including copies of the kits, so agents can't write those files. They are kept here under renamed folders (`dot-claude` = `.claude`, `dot-ai/hooks` = `.ai/hooks`). `.ai/hooks/` (the policy) is needed with **every** AI tool; `.claude/` only with Claude Code. Install them by hand:

```bash
cp -r _staging/kb-kit/dot-claude/.    kb-kit/.claude/      # or straight into your KB
cp -r _staging/kb-kit/dot-ai/hooks/.  kb-kit/.ai/hooks/
cp -r _staging/repo-kit/dot-claude/.  repo-kit/.claude/
cp -r _staging/repo-kit/dot-ai/hooks/. repo-kit/.ai/hooks/
```

## Install

1. **Create the KB.** Copy `kb-kit/` (plus its staged `.claude/` and `.ai/hooks/`) into a new git repo, e.g. `ProjectKB/`.
   - Edit `_kb/kb.conf`: one row per layer (`layer folder prefix index repo consumes`). The default is `backend` (`SPEC-*`) and `frontend` (`FE-*`, consumes backend). One repo only? Keep one row and delete the other index file and map column.
   - Edit `.claude/settings.json` → `additionalDirectories` to the repo paths.
   - Review `.ai/hooks/policy.md`.
2. **Install the repo kit** in each product repo. If the repo already has a `CLAUDE.md` / `AGENTS.md`, first rename it to `CLAUDE.pre-sdd.md` / `AGENTS.pre-sdd.md` (`init-project` moves its content into `.ai/project/` and deletes it). Then copy `repo-kit/` (plus its staged files) into the repo root. Set `.ai/kb.conf` (`KB=../ProjectKB`, `LAYER=<layer>`), the KB path in `CLAUDE.md`, and `additionalDirectories` in `.claude/settings.json`.
3. **First KB session** (in the KB): `Work with the .ai folder: read .ai/ai.md and initialize this knowledge base.` → `init-kb` creates module folders, indexes and map rows.
4. **First session in each repo:** `Work with the .ai folder: read .ai/ai.md and initialize this project.` → `init-project` fills `.ai/project/`, the index's *Project paths* (test tag, commands), and drafts the baseline spec `<PREFIX>-001`. Review and approve it.
5. **Deliver:** drop a requirement into `<Module>/SRS/` and, in the KB: `Task: implement the new requirement in <Module>/SRS/ (run .ai/skills/implement-requirement).` The human-side checklist is in `kb-kit/.ai/TOOLS.md`.

Environment overrides: `SDD_KB` (KB path, for repos), `SDD_REPO_<LAYER>` (repo path, for the KB, e.g. `SDD_REPO_BACKEND`).

## Requirements

- Bash 3.2+ for the validators (Git Bash on Windows).
- Claude Code's policy hook is PowerShell: it runs `pwsh` (PowerShell 7) if installed, otherwise the Windows PowerShell built into Windows. On macOS/Linux install PowerShell 7; without any PowerShell the hook blocks every tool call and says why. Other tools implement `.ai/hooks/policy.md` through their own settings (the agent proposes the config on its first session).
- CI: run `bash .ai/scripts/validate-specs.sh` in each repo (with the KB checked out next to it), plus branch protection, as the backstop for every tool.

## Upgrading a project that uses the old single-repo kit (`specs/` inside the repo)

1. Create a KB from `kb-kit/` with one layer whose `prefix` is `SPEC`.
2. Move each `specs/NNN-slug/` to `_cross-cutting/Implementation/<Layer>/NNN-slug/` (or to `<Module>/Implementation/<Layer>/` with an ID `SPEC-<Module>-NNN`), move the rows of `specs/SPEC-INDEX.md` into the layer index (adding the Folder column), and list every spec in `MODULE-MAP.md` → *Specs without a requirement*.
3. Replace the repo's `.ai/` with `repo-kit/.ai/`, set `.ai/kb.conf`, and run `init-project` (it keeps existing specs and only fills what is missing).
4. `bash _kb/scripts/validate-kb.sh` must exit 0.
