---
name: init-kb
description: First run of a new knowledge base (or after a layer was added to _kb/kb.conf). Checks the layers and their repos, creates the spec indexes, the module folders and MODULE-MAP rows, and points each repo at the KB. Changes no code.
---

# Skill: init-kb

**Use when:** `.ai/ai.md` §0 step 2 says so: a fresh copy of the KB kit, a layer added to `_kb/kb.conf`, or modules missing from `MODULE-MAP.md`. Run each step only where it is still needed; never overwrite existing content.

`_kb/` is human-owned. If `_kb/kb.conf` is wrong (layer names, repo paths, prefixes), tell the human exactly what to change and stop; don't edit it yourself.

## Steps

1. **Read the layers.** Parse `_kb/kb.conf`. For each row check, and report, rather than fix:
   - `$REPO[<layer>]` exists (column `repo`, or env `SDD_REPO_<LAYER>`);
   - it has `.ai/ai.md` and `.ai/kb.conf` (the repo kit). If it hasn't, tell the human to install the repo kit there first (`ai_workflow/repo-kit/`, see its README);
   - its `.ai/kb.conf` → `LAYER` equals this row's layer, and `KB` points back at this folder;
   - prefixes are unique, a `consumes` value names another layer listed **above** it.
2. **Spec indexes.** For each layer whose `index` file is missing, create it from `_kb/templates/spec-index-template.md` (title, layer, repo name, folder). Leave *Project paths* as `TBD`; the repo's `init-project` fills it.
3. **Modules.** Get the module list from the human or from the provider repo's structure (`$REPO/.ai/project/architecture.md`: the business modules / bounded contexts / solution folders). Don't invent modules. For each module, create
   `<Module>/SRS/`, `<Module>/Planning/` and `<Module>/Implementation/<Layer>/` for every layer, each with a `.gitkeep`, and add a row to `MODULE-MAP.md` → *Modules* (one spec column per layer). Do the same for `_cross-cutting/` if a layer folder is missing there.
4. **Map columns.** If the layers differ from the default (backend, frontend), make the spec columns in `MODULE-MAP.md` → *Modules* and *Traceability* match them, one per layer in `_kb/kb.conf` order.
5. **Module list in README.** Fill `README.md` → *Modules* and the project name placeholders.
6. **Tool access.** In Claude Code, `.claude/settings.json` → `permissions.additionalDirectories` must list every repo path. That file is human-owned: if it is wrong, show the human the exact change.
7. **Validate:** `bash _kb/scripts/validate-kb.sh` exits 0.
8. **Report:** layers and repos found (and problems), files and folders created, what the human must still do (fix `kb.conf`, settings, install the repo kit, run `init-project` in each repo so it fills *Project paths* and drafts its baseline spec). **Don't change any code.**
