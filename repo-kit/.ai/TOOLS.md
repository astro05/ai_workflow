# Using `.ai/` with any AI tool

> For humans. AI agents: read `.ai/ai.md` instead.

Claude Code loads `.ai/` through `CLAUDE.md`, and tools that read `AGENTS.md` (Codex, Cursor, Copilot, OpenCode, Aider, …) are pointed to it there. Any other tool needs to be told at the start of each session.
This works the same way in Claude Code, Codex, OpenCode, Antigravity, Cursor, Copilot, Gemini CLI, Aider, and any other agent that can read files.

Requirements, plans and specs are **not in this repo**. They live in the shared knowledge base (the KB), next to this repo or wherever `SDD_KB` points (see `.ai/kb.conf`).

## 0. Install in a repo

1. If the repo already has a `CLAUDE.md` or `AGENTS.md`, rename it to `CLAUDE.pre-sdd.md` / `AGENTS.pre-sdd.md` first (`init-project` moves its content into `.ai/project/`). Then copy `.ai/` (including `.ai/hooks/`, needed by every tool), `CLAUDE.md`, `AGENTS.md` and (for Claude Code) `.claude/` into the repo root. `CLAUDE.md` is loaded by Claude Code; `AGENTS.md` by Codex, Cursor, Copilot, OpenCode, Aider and others.
2. Put the KB next to the repo, or set the environment variable `SDD_KB` to its path. Set `KB` and `LAYER` in `.ai/kb.conf`; `LAYER` must have a row in `$KB/_kb/kb.conf`. Your AI tool must be allowed to read and write the KB: in Claude Code, `.claude/settings.json` → `permissions.additionalDirectories` (or `claude --add-dir <path>`); other tools need the equivalent "additional workspace folder" setting. Adjust the KB path in `CLAUDE.md` too.
3. Claude Code's policy hook needs PowerShell: it runs `pwsh` (PowerShell 7) if installed, otherwise Windows PowerShell. On macOS/Linux install PowerShell 7; without it the hook blocks every tool call and says why.
4. Review `.ai/hooks/policy.md`, which lists what agents may never do (git push, destructive DB commands, secrets, …), and adjust it for this repo. In its first session, the agent implements it in its own tool's settings and asks you to approve the diff.
5. Start the first session with:
   ```
   Work with the .ai folder: read .ai/ai.md and initialize this project.
   ```
   The agent runs `init-project`: it fills `.ai/project/` (moving an existing `CLAUDE.md` / `AGENTS.md` there verbatim), records paths and commands in the KB's spec index, and drafts the baseline spec `<PREFIX>-001`. Review that spec and approve it.

This works for new and existing repos. In an existing repo, current code is left alone until a task changes it.

## 1. Start every session with

```
Work with the .ai folder: read .ai/ai.md first and follow its reading order.
Task: <your task>
```

In tools that support `@` file mentions (most of them), `@.ai/ai.md` attaches the file directly:

```
@.ai/ai.md  Task: <your task>
```

To take one requirement through every layer in one session, start the tool in the KB instead (see the KB's `.ai/TOOLS.md`).

## 2. Pick a persona or skill for the task

| Want | Say |
|---|---|
| A new requirement arrived | Save it in `<KB>/<Module>/SRS/`, then: "Run `.ai/skills/intake-requirement/SKILL.md` for the new file in `<Module>/SRS/`". The agent writes the plan in `<KB>/<Module>/Planning/NNN-slug/plan.md`; answer its questions and set its `Status: Approved` before specs are drafted |
| Turn an idea into a spec | "Act as `.ai/agents/spec-architect.md`. New spec for: <feature>" |
| Scaffold a spec folder | "Run the skill `.ai/skills/new-spec/SKILL.md` for: <module>" |
| Implement | "Act as `.ai/agents/core-engineer.md`. Implement <SPEC-ID> AC-01..AC-03" |
| Write tests | "Act as `.ai/agents/test-engineer.md` for <SPEC-ID>" |
| Check code vs. spec | "Run `.ai/skills/sync-spec/SKILL.md` on this branch" |
| Check contracts | "Run `.ai/skills/verify-contract/SKILL.md` for <SPEC-ID>" |
| Security review | "Act as `.ai/agents/security-auditor.md` and review this diff" |
| Debug a failing run | "Run `.ai/skills/troubleshoot/SKILL.md`: <symptom>" |

## 3. Long sessions

Agents forget instructions as context fills up. If an agent starts skipping the spec loop, say:
```
Re-read .ai/rules/00-spec-driven-rules.md and continue.
```

## 4. Approve plans and specs yourself

Agents only draft. You change `Status: Draft` → `Approved` in the plan (`<KB>/<Module>/Planning/NNN-slug/plan.md`), and in each `<KB>/<Module>/Implementation/<Layer>/NNN-*/spec.md` and its row in the layer's spec index, then tell the agent to continue.

## 5. See what implements what

`<KB>/MODULE-MAP.md` lists, per module, every requirement with its plan, the specs of every layer that implement it, and its trace status. Each spec's `changelog.md` logs every code change made against it.

## 6. Teach the agents once

When you correct an agent with something that applies beyond the task (a fix, a pattern, a convention), it records it in `<KB>/.ai/memory/` so later sessions, in every repo, follow it.
