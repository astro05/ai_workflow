---
name: rule-follow-existing-coding-patterns
description: Before writing code in any repo, find how the surrounding code and similar features already do it and match that; never introduce a new style
type: rule
layer: all
added: YYYY-MM-DD
---

Always follow the coding pattern that already exists in the repo, in the file, its module and in similar features, rather than introducing a style of your own.

**Why:** Agent code that "works and passes its tests" but uses its own naming, aliases, comment density or helper style gets rewritten in review. Matching the codebase is cheaper than defending a new style.

**How to apply:** In every repo, before writing new code:
- Open the neighbouring files and one similar existing feature. Match their naming (aliases, parameters, private prefixes), file layout, dependency injection style, helpers, error handling, test style and comment density.
- Reuse existing services, helpers and base-class hooks instead of writing parallel ones.
- If two existing patterns conflict, follow the one in the same module and mention the conflict to the human.
- If the existing pattern looks wrong, keep to it and raise the improvement with the human; don't silently switch styles.
- Patterns the human has approved explicitly (recorded here as `pattern-*` entries) are part of the existing pattern from then on.
- This sits under each repo's `.ai/project/` conventions; if a repo document already states a convention, that document wins.
