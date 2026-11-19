---
name: sync-spec
description: Detect drift between code changes and their owning specs (and, in a consumer layer, the provider contracts they use); classify each drift as a code defect, a spec gap or an orphan and produce a reconciliation report.
---

# Skill: sync-spec

**Use when:** reviewing a PR, after a bug fix, before closing out a requirement, or whenever code and spec may disagree.

## Steps

1. **Collect the changes:** `git diff --name-only <base>...HEAD` (default base: the integration branch from `.ai/project/commit-conventions.md`).
2. **Map files to specs:** for each changed path under the source and tests roots, find the spec of this layer (`$KB/<INDEX>`) whose §2.1 Module Placement owns it. A file no spec owns is an **orphan**, which counts as drift (unless it is grandfathered and its behavior didn't change).
3. **Compare each owning spec with the code:**
   - §3 contracts: operation names, input and output fields, types, optionality, enums, routes and status codes, messages.
   - §4.2 error codes: the codes the code raises vs. the codes the spec lists, in both directions.
   - §4.1 invariants: is each one still enforced?
   - §5: does each `Test Reference` exist, and do tests reference ACs that exist?
   - New dependencies or architectural choices that are missing from §2.4.
   - `changelog.md`: does every code change on the branch have a row (rule 00, loop step 5)?
   - **Consumer layers:** do the models and calls match §3 of the provider specs in `<ProviderLayer> Specs`, at their current version?
4. **Classify each drift:**
   - **Code defect:** the spec is right and the code is wrong. Fix the code through loop step 2 (failing test first).
   - **Spec gap:** the code reveals intended behavior that the spec lacks. Propose an amendment as an Open Question or a diff, **with no semantic edit to an Approved spec without human approval.**
   - **Contract drift** (consumer layers): this layer and the provider spec disagree. Decide with the human which side changes; a provider change is handed off to its repo.
   - **Orphan:** code with no spec. Either a spec gets written (`new-spec`), or the code gets deleted.
5. **Report:**

   | Spec | Section | Code location | Drift | Class | Proposed action |
   |---|---|---|---|---|---|

6. Exit condition: the report is empty, or every row has an owner and an action. Note the result in the requirement's `$KB/MODULE-MAP.md` row if the human asks.
