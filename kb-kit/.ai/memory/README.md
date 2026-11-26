# .ai/memory — Learned fixes, patterns and conventions

Shared, versioned memory for every AI session started in this knowledge base or in one of its repos, whichever tool runs it.
It holds what a human had to tell an agent (corrections, fixes, conventions, preferred patterns), so the next session (and the next teammate's agent) doesn't repeat the mistake.

**Read this index every session** (`.ai/ai.md` §1; the repos read it too). Open an entry when its topic and `layer` touch your task.

Why here and not in the tool's own memory: tool memory is per user and per machine, and is often blocked by the policy hook. This folder is reviewed and committed like any KB change, so the whole team shares it.

## Format

One rule per file, `kebab-case.md`, with frontmatter:

```markdown
---
name: <slug, same as the file name>
description: <one line, used to decide relevance>
type: fix | convention | pattern | rule
layer: kb | <layer from _kb/kb.conf> | all
added: YYYY-MM-DD
---

<the rule in one or two lines>

**Why:** <what went wrong, or why the human wants it; who asked and when>
**How to apply:** <repo/layer, files or situations; a short wrong → right example if it helps>
```

File name prefix by type: `fix-` (a mistake and its correct form), `convention-` (naming, structure, style), `pattern-` (a preferred way to build something), `rule-` (how agents should work). Add a short layer tag for layer-specific entries, e.g. `fix-be-ef-migrations.md`, `convention-fe-signal-inputs.md`.

Entries rank as standing human instructions (`.ai/ai.md` §6), but because agents write them they rank **below** the policies and every rule 00: above the repos' rules 01–03, below their `.ai/project/`. An entry never relaxes a gate, an approval, the traceability or a ban; when a human asks for that, tell them it is a change to rule 00 or the policy, which a human edits. A repo's `.ai/project/` document that states a convention wins over an entry.

## Index

Add one line per entry: `- [<name>](<file>.md): <hook>`.

- [rule-record-fixes-and-conventions](rule-record-fixes-and-conventions.md): whenever a human gives a general fix, pattern or convention, record it here in the same turn
- [rule-follow-existing-coding-patterns](rule-follow-existing-coding-patterns.md): before writing code in any repo, match how the surrounding code and similar features already do it; never introduce a new style
