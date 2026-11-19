# Module Map: SRS ↔ Plan ↔ Specs

The traceability map for every module: which requirement (SRS) is planned where, and implemented by which specs in each layer.
**Agents update this file in the same change that creates or amends a requirement, plan or spec** (see `.ai/skills/plan-requirement` here and `intake-requirement` / `new-spec` in each repo). `_kb/scripts/validate-kb.sh` fails if a `REQ-*` or spec ID exists in the KB but is missing from this file, or if a link here does not resolve.

- **Requirement**: an SRS folder `<Module>/SRS/NNN-slug/` with ID `REQ-<Module>-NNN`. It sits under the module that **owns** the request; the specs it drives may be in other modules.
- **Plan**: `<Module>/Planning/NNN-slug/plan.md`, same folder name as its requirement: approach, work breakdown (task status), questions for the product owner.
- **Specs**: one column per layer of `_kb/kb.conf`. Default: **Backend specs** `SPEC-<Module>-NNN` in `<Module>/Implementation/Backend/` ([`BACKEND-SPEC-INDEX.md`](BACKEND-SPEC-INDEX.md)) and **Frontend specs** `FE-<Module>-NNN` in `<Module>/Implementation/Frontend/` ([`FRONTEND-SPEC-INDEX.md`](FRONTEND-SPEC-INDEX.md)). Rename, add or drop columns when the layers change.
- **Trace status**: `New` (SRS received, not analysed) · `Planning` (plan drafted, not approved yet) · `Specifying` (specs drafted, not all approved) · `Approved` (all specs approved) · `In progress` (implementation started) · `Done` (all specs at full coverage) · `Partial` (with a note on what is missing, e.g. "frontend not specified").

## Modules

One row per module folder. Add a row in the same change that creates the module folder.

| Module | SRS | Backend specs | Frontend specs |
|---|---|---|---|
| [_cross-cutting](_cross-cutting/) | — | — | — |

## Traceability

One row per requirement. List **every** spec the requirement drives, in any module. Planned specs that don't exist yet are plain text (`new: SPEC-Billing-002 (invoice export)`); existing ones are links relative to the KB root.

| Requirement | Title | Plan | Backend specs | Frontend specs | Trace status | Notes |
|---|---|---|---|---|---|---|

## Specs without a requirement

Baselines and purely technical specs. Link them to a requirement when one is added.

| Spec | Reason |
|---|---|
