# <Project>KB

The shared knowledge base for <Project>, organised by business module. Every module goes through three stages:

1. **PRD**: the requirements and documents, as the business provides them.
2. **Planning**: exploration, approach, work breakdown, and questions for the product owner.
3. **Implementation**: one spec per layer (backend, frontend, …), and a log of every code change made against them.

Every product repo reads and writes its specs here. The layers are listed in [`_kb/kb.conf`](_kb/kb.conf):

| Layer | Repo | AI workflow entrypoint | Writes specs to | Spec IDs |
|---|---|---|---|---|
| backend | `<backend repo>` | `<backend repo>/.ai/ai.md` | `<Module>/Implementation/Backend/` | `SPEC-<Module>-NNN` |
| frontend | `<frontend repo>` | `<frontend repo>/.ai/ai.md` | `<Module>/Implementation/Frontend/` | `FE-<Module>-NNN` |
| **this KB** (PRD → plan → specs → code in every repo) | — | `.ai/ai.md` (skill `implement-requirement`) | plans, every layer's specs, plus the code in each repo via its own `.ai/` | — |

**Location.** The repos expect this folder at the `KB` path in their `.ai/kb.conf` (default `../<Project>KB`); the env variable `SDD_KB` overrides it. This folder finds the repos through `_kb/kb.conf` (env `SDD_REPO_<LAYER>` overrides). Claude Code gets access through `permissions.additionalDirectories` in each `.claude/settings.json`.

---

## Layout

```
<Project>KB/
├── README.md                 this file
├── MODULE-MAP.md             traceability: requirement → plan → specs of every layer, per module
├── BACKEND-SPEC-INDEX.md     registry of backend specs  (SPEC-*)   one index per layer in _kb/kb.conf
├── FRONTEND-SPEC-INDEX.md    registry of frontend specs (FE-*)
├── GLOSSARY.md               the shared business language: every plan, spec, test and identifier uses its terms
├── _decisions/               system-wide decision records (NNN-slug.md = DEC-NNN; README says when and how)
├── CLAUDE.md, AGENTS.md, .ai/, .claude/   AI workflow for sessions started here (see .ai/TOOLS.md)
├── _kb/
│   ├── kb.conf                           the layers: folder, ID prefix, index, repo path, which layer each consumes
│   ├── scripts/validate-kb.sh            the validator (every repo calls it)
│   └── templates/                        requirement-template.md (README of a requirement), spec-index-template.md
├── _cross-cutting/           things that belong to no single module (baseline specs, app shell, …)
│   ├── PRD/  Planning/  Implementation/<Layer>/
└── <Module>/                 one folder per business module
    ├── PRD/                  1. requirements, as received
    │   └── NNN-slug/            one requirement: README.md (metadata) + the original documents
    ├── Planning/             2. how we will deliver it
    │   └── NNN-slug/            plan.md (same NNN-slug as the requirement), plus any working notes
    └── Implementation/       3. what we build, and the trace of every code change
        └── <Layer>/             Backend/, Frontend/, … (the folder column of _kb/kb.conf)
            └── NNN-slug/        one spec: spec.md + changelog.md
```

The plan template is `.ai/templates/plan-template.md`; the spec templates live in each repo (`.ai/templates/spec-template.md`).

Modules: <list the module folders here; `init-kb` fills it>.
A new module folder is added only when the code gains that module.

## IDs

| Kind | Folder | ID | Example |
|---|---|---|---|
| Requirement | `<Module>/PRD/NNN-slug/` | `REQ-<Module>-NNN` | `Billing/PRD/001-invoice-export/` = `REQ-Billing-001` |
| Plan | `<Module>/Planning/NNN-slug/plan.md` | the requirement's ID | `Billing/Planning/001-invoice-export/` plans `REQ-Billing-001` |
| Spec | `<Module>/Implementation/<Layer>/NNN-slug/` | `<PREFIX>-<Module>-NNN` | `Billing/Implementation/Backend/002-export-api/` = `SPEC-Billing-002` |
| Cross-cutting | `_cross-cutting/{PRD,Planning,Implementation/<Layer>}/NNN-slug/` | `REQ-NNN` · `<PREFIX>-NNN` | `_cross-cutting/Implementation/Backend/001-core-system/` = `SPEC-001` |

A plan has no number of its own: its folder name is the requirement's. Requirement and spec numbers are per module **and** per layer, and never reused. They are independent of each other: `MODULE-MAP.md` and the plan's §4 say which specs implement which requirement.

## How a requirement flows

```
 PRD             1. Human drops the requirement     <Module>/PRD/<files>   (or PRD/NNN-slug/ directly)
 Planning        2. Agent files and plans it        PRD/NNN-slug/README.md, Planning/NNN-slug/plan.md,
                                                    MODULE-MAP row                    skill: plan-requirement
                 3. Product owner answers, human approves the plan       Status: Draft → Approved
 Implementation  4. Specs, layer by layer           Implementation/<Layer>/NNN-slug/  Draft   skill: new-spec / amend
                    (providers first; a consumer spec links the provider specs whose §3 it uses)
                 5. Human approves the specs        Status: Draft → Approved  (spec + index, and the test entry points)
                 6. Code, task by task              each plan §5 task is built end to end through its layers (provider
                                                    part first), built red → green one AC at a time and reviewed;
                                                    every change logged in the spec's changelog.md, plan §5 tasks,
                                                    index and MODULE-MAP updated; human reviews each task
```

Provider specs normally come first because consumers build against their contracts. A change in one layer only skips the others; the plan's §4 and the requirement's `MODULE-MAP.md` row say so.

## Who edits what

| File | Humans | Agents |
|---|---|---|
| Requirement documents in `PRD/` | write them | **read only**; may move loose files into a `NNN-slug/` folder and add its `README.md` |
| `Planning/NNN-slug/plan.md` | answer its questions (with the product owner), approve (`Status`) | draft and revise; never set `Approved` |
| `spec.md`, `changelog.md` | review, approve (`Status`) | draft and amend, log every code change in `changelog.md`; never set `Approved` / `Deprecated` |
| `*-SPEC-INDEX.md`, `MODULE-MAP.md` | review | keep in sync in the same change as the spec |
| `.ai/memory/` | review, correct | record every general fix or convention a human gives |
| `GLOSSARY.md` | review, correct | add or sharpen a term in the same change that settles it |
| `_decisions/` | review, approve, deprecate (`Status`) | draft new decision records (`Draft`); never rewrite an `Approved` one |
| `_kb/`, `.ai/hooks/`, `.claude/` | own | do not edit (the policy hook blocks it) |

Paths inside a spec (§2.1, Verification Matrix test references, mentions of `.ai/…`) are relative to **that layer's repo root**, not to this KB.

## Validate

```bash
bash _kb/scripts/validate-kb.sh                      # everything
bash _kb/scripts/validate-kb.sh --layer backend      # what the backend repo's .ai/scripts/validate-specs.sh runs
```

It fails on: a wrong ID for its folder, two folders with the same number (e.g. after merging two branches), a plan without a matching requirement folder or with an invalid Status, a spec missing from its index or from `MODULE-MAP.md`, Status / Version / Coverage drift between spec and index, a spec Version with no `changelog.md` row, a dependency / requirement / provider-spec link that doesn't resolve, an invalid Verification Matrix, an AC marked Verified whose test file doesn't exist in the repo or doesn't carry the tag `<SPEC-ID>-AC-NN`, and an Approved plan or spec that still has TBD/TODO, template `<placeholders>` or unanswered questions (plan §6, spec §1.4). It warns about requirement files dropped straight into `PRD/` that have not been through intake yet. Bash 3.2+ (Git Bash on Windows).

## Versioning

This folder is its own git repository. Requirements, plans, specs, the indexes, the map, the glossary, the decision records and the memory are reviewed in PRs like code (`docs(prd|plan|specs|map|glossary|decisions|memory): …` commits with a `Refs: REQ-…` footer, see `.ai/rules/00-orchestration-rules.md`); the code PR in each product repo names the spec versions it implements.
