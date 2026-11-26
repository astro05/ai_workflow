---
name: hand-off-session
description: Write a short hand-off note so another tool, a session in another directory, or a colleague can continue a requirement. Only when the work has to move; otherwise the KB already carries the state.
---

# Skill: hand-off-session

**Use when:** the work moves to another AI tool, another repo/directory session, or another person, or a side task must be split off. Otherwise continue, clear or compact at the gate (`implement-requirement` → *Phase boundaries*).

## Steps

1. First write anything still only in chat (decisions, answers, terms, fixes) into the plan, spec, `GLOSSARY.md` or `.ai/memory/`.
2. Write `hand-off-<REQ-or-SPEC-ID>-<date>.md` in the OS temp directory (not the KB or a repo) and give the human its full path. It **points** to the KB files rather than repeating them:
   - **Where we are:** phase, plan §5 task, layer, persona, Trace status.
   - **Pointers:** requirement, plan, specs and versions, branch and uncommitted files per repo.
   - **Not written anywhere else:** dead ends, ruled-out causes, commands that worked.
   - **Next:** the next action, the open plan §5 tasks, questions waiting on humans, and the `.ai/skills` to run first.
3. Redact secrets and personal data.
