---
name: rule-record-fixes-and-conventions
description: Standing instruction: whenever a human gives a general fix, coding pattern or convention, save it here so later sessions don't repeat the error
type: rule
layer: all
added: YYYY-MM-DD
---

When a human gives a correction, a general fix, a coding pattern or a convention that applies beyond the current task (in the KB or any repo), record it in `.ai/memory/` in the same turn, without being asked again.

**Why:** The team wants recurring errors to go down across sessions and across people: a fix given once should not have to be given twice.

**How to apply:**
- One entry per rule, in the format of `.ai/memory/README.md`, plus one line in its Index.
- Before writing, check the Index for an entry on the same topic and update it instead of duplicating. If a new instruction contradicts an old one, rewrite or delete the old one.
- Don't record what the repos' `.ai/` folders, `CLAUDE.md` or `README.md` already state; record only what the human had to tell you. If a fix is really a gap in a repo's `.ai/rules` or `.ai/project/`, tell the human it could go there too.
- Skip one-off, task-specific instructions.
- Write the entry in the KB even when the session was started in a repo (`$KB/.ai/memory/`).
- After saving, tell the human in one line what was recorded. Memory changes are committed like any KB change: `docs(memory): <what>`, only when the human asks.
