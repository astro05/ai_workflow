# Using `.ai/` in the knowledge base

> For humans. AI agents: read `.ai/ai.md` instead.

Start your AI tool **in this folder** when you want one session to take a requirement from the PRD to code in every repo it touches. (You can still start it inside one repo to work on that layer only; the repos read and write their specs here too.)

Claude Code loads `.ai/` through `CLAUDE.md`, and tools that read `AGENTS.md` (Codex, Cursor, Copilot, OpenCode, Aider, …) are pointed to it there. Any other tool needs to be told at the start of each session. Either way, the start-of-session prompts below work the same in every tool.

## 0. Setup

1. Keep the folders side by side, as `_kb/kb.conf` lists them (default):
   ```
   <parent>/<Project>KB      this folder
   <parent>/backend          the backend repo (repo kit installed)
   <parent>/frontend         the frontend repo (repo kit installed)
   ```
   Elsewhere, set `SDD_REPO_<LAYER>` (e.g. `SDD_REPO_BACKEND`) here, and `SDD_KB` for sessions started in the repos.
2. Claude Code: `.claude/settings.json` gives the session access to the repos (`permissions.additionalDirectories`) and runs the policy hook. Check with `/permissions` in the first session. The hook needs PowerShell (`pwsh` if installed, otherwise Windows PowerShell); on macOS/Linux install PowerShell 7, or the hook blocks every tool call and says why. Other tools: add the repos as additional workspace folders.
3. Review `.ai/hooks/policy.md` (what agents may never do from here).
4. First session: `Work with the .ai folder: read .ai/ai.md and initialize this knowledge base.` The agent runs `init-kb`.

## 1. Implement a requirement

Each module folder has three stages: **PRD** (you) → **Planning** (agent) → **Implementation** (agent: one spec per layer, then code, with every code change logged in the spec's `changelog.md`).

1. Save the requirement documents (CR, PRD, meeting notes, mock-ups) in `<Module>/PRD/` (loose, or in a `NNN-slug/` folder).
2. Start the session with:
   ```
   Work with the .ai folder: read .ai/ai.md first and follow its reading order.
   Task: implement the new requirement in <Module>/PRD/ (run .ai/skills/implement-requirement).
   ```
   Only want the plan for now? `Task: plan the new requirement in <Module>/PRD/ (run .ai/skills/plan-requirement).`
3. The agent stops at each gate. Your part:

   | Gate | You |
   |---|---|
   | After planning | Read `<Module>/Planning/NNN-slug/plan.md`; answer each round of §6 questions (with the product owner; "yes" accepts the agent's proposal) and paste them back; check the §5 tasks are small, end to end, and have the right "Depends on"; name the branch in each repo; when happy, set the plan's `Status: Approved` |
   | After a layer's specs | Review, including §5 *Test entry points* (where tests will go, and what each misses); set `Status: Approved` in each `spec.md` and in that layer's `*-SPEC-INDEX.md` |
   | After each task | Review the working behaviour (demo or test evidence), the diff per repo and the review findings; commit (or ask the agent to) |

4. Continue a requirement later with: `Task: continue REQ-<Module>-NNN (run .ai/skills/implement-requirement).`

## 2. Other things to ask

| Want | Say |
|---|---|
| Only file and plan a new requirement | "Run `.ai/skills/plan-requirement` for the new file in `<Module>/PRD/`" |
| Feed back the product owner's answers | "Answers to the questions in `<Module>/Planning/NNN-slug/plan.md`: Q-01 …, Q-02 …" |
| Status of everything | "Summarise MODULE-MAP.md and run the KB validator" |
| Drift check for one requirement | "Run sync-spec in every repo for REQ-<Module>-NNN" |
| Teach the agents something for good | Just say it ("from now on …"); the agent records it in `.ai/memory/` (and proposes a lint/CI check when the fix is mechanical). Review those files like code. |
| Settle a business term | "We call it X, not Y"; the agent records it in `GLOSSARY.md` |
| Review a branch | "Run `.ai/skills/review-change` in `<repo>` since `<branch or commit>`" |
| Fix a bug | "Run `.ai/skills/fix-bug` in `<repo>`: <symptom>" |
| Look back on a session | "Run `.ai/skills/improve-workflow`": environment improvements, most severe first |
| Move the work to another tool or a colleague | "Run `.ai/skills/hand-off-session`" |

## 3. Long sessions

Agents forget instructions as context fills up, and reason less sharply as it fills. Change context only at a gate (a phase boundary), in this order of preference: continue; clear (the plan, specs and map carry the state, the norm between tasks); hand off (other tool, directory or person); compact with an instruction naming the next phase. If an agent starts skipping gates or the spec loop, say:
```
Re-read .ai/rules/00-orchestration-rules.md and the current repo's .ai/rules/00-spec-driven-rules.md, and continue.
```

## 4. Git

This folder is its own repo: requirements, plans, specs and memory are reviewed in PRs like code. Code changes are committed in each product repo on its own branch. Agents never push.
