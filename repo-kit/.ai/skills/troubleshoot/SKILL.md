---
name: troubleshoot
description: Where to look when building, running, testing, logging, database, messaging or dependency-injection problems occur in this repo.
---

# Skill: troubleshoot

**Use when:** debugging a local run, a build or test failure, or a runtime failure.

> Filled by init-project from the project's debugging docs and `.ai/project/commands.md`. Until then, use the generic steps below.

## Steps

1. **Reproduce** with the exact command from `.ai/project/commands.md`, from the repo root, and capture the full output.
2. **Check `$KB/.ai/memory/`** for `fix-` entries of this layer: a known local-environment fix may already exist.
3. **Look where the project says:** <run the app locally; where logs go; where migrations live; how messaging / background jobs are configured; where dependency injection and routing are registered>.
4. **Narrow it down:** run the single failing test or file; build only the affected project or library.
5. **Don't fix what isn't yours:** a failure outside the task is reported to the human with the output; never weaken a test or check to get green.
6. **Record the fix:** if the human gives a general fix, or you found a reusable one with them, add a `fix-` entry to `$KB/.ai/memory/` (its README has the format).
