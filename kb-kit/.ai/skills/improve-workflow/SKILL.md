---
name: improve-workflow
description: Look back on a delivery session and propose improvements to the agents' environment (pointers, checks, conventions, memory, commands, access), most severe first. Changes the environment, never the product code.
---

# Skill: improve-workflow

**Use when:** a human asks for it, at close-out of `implement-requirement`, or after a session that needed repeated corrections. Run it before the session's context is cleared.

Agents propose, humans decide: `.ai/memory/` entries may be written once accepted; everything human-owned (`_kb/`, hooks, tool settings, CI, `.ai/rules/`, `.ai/project/`) is shown as a diff for the human.

## Steps

1. **Review the session**, the plan, specs and changelogs it touched, and the memory entries in force.
2. **Find the friction**, each tied to a moment in the session: slow navigation (a missing pointer); a mistake a linter, test, hook or the validator could have caught (or an existing check that is unwired); a review miss or false alarm; a correction given twice or a memory entry that misled; an instruction that changed nothing or is stale; an expensive or repeated command; information the agent couldn't reach.
3. **Classify each fix:** mechanical (a pattern a tool can detect) → propose an automated check in the repo's own tooling; judgement → a convention in `.ai/project/conventions.md` or a `.ai/memory/` entry.
4. **Present**, most severe first: `# | what happened | proposed change (file or check) | mechanical / judgement`.
5. **Apply** what the human accepts.
