---
name: init-project
description: First run of the .ai kit in a repo. Fills .ai/project/ and .ai/kb.conf from the real repo, creates this layer's spec index in the KB with the project's paths and commands, and drafts the baseline spec <PREFIX>-001.
---

# Skill: init-project

**Use when:** `.ai/project/overview.md` still has `<placeholders>`, `$KB/<INDEX>` is missing, its *Project paths* still say `TBD`, or it has no spec rows. Run it once per repo; on a re-run, do only the steps still needed.
If the KB itself is missing, stop and ask the human to provide it (a KB is created from the KB kit, never inside this repo).

## Steps

1. **Detect the project.** Read the root manifest files (`package.json`, `pyproject.toml`, `go.mod`, `Cargo.toml`, `pom.xml`, `*.sln` / `*.csproj`, `angular.json`, …), the README, CI config, and the top-level folders. Note these, **verified, not guessed**:
   - Language, framework, runtime version, package manager
   - Source root and tests root (or "colocated"), test framework and naming style
   - Build, test (whole suite, one file, one tag), lint / format and type-check commands (from scripts, Makefile or CI config)
   - The module list (folders, projects or feature areas) and the layering
   - How a test can carry the tag `<SPEC-ID>-AC-NN` in this framework (category / trait / marker / name prefix)
2. **Fill `.ai/project/`.**
   - If the repo has a `CLAUDE.pre-sdd.md` / `AGENTS.pre-sdd.md` (renamed at install), or a `CLAUDE.md`, `AGENTS.md` or similar agent file with project content, **move that content verbatim** into the matching `.ai/project/*.md` files (keep each file's header line). Then delete the `*.pre-sdd.md` files, and make sure `CLAUDE.md` and `AGENTS.md` are the kit's loaders (no project content); if one is missing, tell the human to copy it from the kit.
   - Fill the remaining `<placeholders>` from step 1. Leave unknowns as `<placeholder>` and list them in your report; don't invent.
   - Record the team's branch convention in `commit-conventions.md` → *Branches* (ask if not documented).
3. **Fill `.ai/kb.conf`:** `KB` (path to the KB relative to the repo root) and `LAYER`. Make sure the KB path in `CLAUDE.md` matches.
4. **Check the layer in the KB.** `$KB/_kb/kb.conf` must have a row for `LAYER` (folder, prefix, index, repo, consumes). If it doesn't, **stop** and ask the human to add it: `_kb/` is human-owned. Read the row: it gives `<Layer>`, `<PREFIX>`, `<INDEX>` and `Consumes`.
5. **The index.** If `$KB/<INDEX>` is missing (usually `init-kb` has already created it), create it from the KB's template and replace the layer and repo names:
   ```bash
   . .ai/kb.conf; KB="${SDD_KB:-$KB}"
   cp "$KB/_kb/templates/spec-index-template.md" "$KB/<INDEX>"
   ```
   **In either case**, fill its **Project paths** table with what you found in step 1 (source root, tests root, test tag, test / lint / build commands), replacing every `TBD`. Leave a row `TBD` only if you could not verify it, and list it in your report.
6. **Module folders.** Every module from step 1 needs `$KB/<Module>/{PRD,Planning,Implementation/<Layer>}/` (each empty folder with a `.gitkeep`) and a row in `$KB/MODULE-MAP.md` → *Modules*. Create what is missing; never rename existing module folders (ask if names differ).
7. **Draft the baseline spec with the `new-spec` skill:** folder `$KB/_cross-cutting/Implementation/<Layer>/001-core-system/`, ID `<PREFIX>-001`, `Requirements: none`, registered in `$KB/MODULE-MAP.md` → *Specs without a requirement*.
   - **New project:** the system baseline. Leave the product vision and tech stack as §1.4 Open Questions.
   - **Existing project:** describe the system *as it is today*, not as it should be. Document the current architecture in §2 (map the real layers onto rule 01's generic layers), list the main modules with their existing paths in §2.1, and cite `.ai/project/` for the existing stack choices in §2.4.
8. **Fill the stack skills:** `.ai/skills/add-module/SKILL.md` from `.ai/project/architecture.md` → *Module registration flow*, and `.ai/skills/troubleshoot/SKILL.md` from the project's debugging docs and `commands.md`. Keep their frontmatter.
9. **Existing code is grandfathered.** Don't write specs for every module up front. A module gets its own spec the first time a task changes its behavior (rule 00).
10. **Validate:** `bash .ai/scripts/validate-specs.sh` must exit 0.
11. **Report to the human:** what you detected, what was moved from `CLAUDE.md`/`AGENTS.md`, the remaining placeholders and open questions, the KB files created, and that `<PREFIX>-001` is waiting for their review. Remind them to review `.ai/hooks/policy.md` and the tool settings. **Don't change any code.**
