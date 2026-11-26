---
name: add-module
description: Add a new module / feature folder (projects or folders, registration, entrypoints) following the project architecture in .ai/project/architecture.md.
---

# Skill: add-module

**Use when:** a new feature needs its own module (or, in a UI layer, its own feature folder). An `Approved` spec must own the module first (rule 00), and its §2.1 names the paths.

> Filled by init-project from `.ai/project/architecture.md` → *Module registration flow*. Until then, follow that section directly; if it is empty, stop and ask the human how modules are added.

## Steps

1. **Read** `.ai/project/architecture.md` → *Core Organization Pattern* and *Module registration flow*, and open one existing module as the reference.
2. **Create the module's folders / projects** exactly as the reference module has them: <list from architecture.md, e.g. contracts, domain, application, infrastructure, tests>.
3. **Register it:** <the registration steps from architecture.md, e.g. a `Register<Feature>Services` method called from the composition root; route entries; solution / workspace entries>.
4. **Add the entrypoints** the spec's §3.2 lists (controllers, routes, handlers, components), in the place architecture.md names.
5. **KB:** if the module has no folder in `$KB` yet, create `$KB/<Module>/{PRD,Planning,Implementation/<Layer>}/` (with `.gitkeep`) and add it to *Modules* in `$KB/MODULE-MAP.md`.
6. **Verify:** build and tests pass (`.ai/project/commands.md`); log the change in the spec's `changelog.md` (rule 00, loop step 5).
