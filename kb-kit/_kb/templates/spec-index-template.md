# <Layer> Spec Index

The registry of every **<layer>** spec (repo `<repo name>`). **Read it first in every <layer> task** (see `<repo>/.ai/ai.md`).
Lives at the KB root as the `index` of its row in `_kb/kb.conf` (e.g. `BACKEND-SPEC-INDEX.md`). Specs live in this knowledge base, module-wise: `<Module>/Implementation/<Layer>/NNN-slug/`.
`_kb/scripts/validate-kb.sh` (run from the repo as `bash .ai/scripts/validate-specs.sh`) fails if a spec folder is missing from this table, if its Status here differs from the spec's own metadata, or if a Folder below does not exist.

## Project paths

Layout and commands follow `<repo>/.ai/project/` (source of truth). Paths in a spec's §2.1 and Verification Matrix are relative to the **repo root**, not to this KB.

| Key | Path |
|---|---|
| Source root | TBD |
| Tests root | TBD (or "colocated: `<pattern>`") |
| Test tag | TBD: how a test names the AC it verifies, e.g. `[TestCategory("SPEC-Billing-002-AC-03")]`, `it('[FE-Billing-001-AC-03] …')`, `@pytest.mark.spec("SPEC-Billing-002-AC-03")` |
| Test command | TBD |
| Lint / type-check command | TBD |
| Build command | TBD |

## Specs

| Spec ID | Module | Status | Version | Coverage | Owner | Last Updated | Depends On | Folder |
|---|---|---|---|---|---|---|---|---|

## Folder layout

- A module spec lives in `<Module>/Implementation/<Layer>/NNN-slug/` (`spec.md` + `changelog.md`) and has ID `<PREFIX>-<Module>-NNN`. Empty folders hold a `.gitkeep`.
- `NNN` is numbered **per module and per layer**: the next number is the highest `NNN` in `<Module>/Implementation/<Layer>/` plus 1. The slug does not repeat the module name.
- Cross-cutting specs that belong to no single module live in `_cross-cutting/Implementation/<Layer>/NNN-slug/` with ID `<PREFIX>-NNN`.
- Dependencies between specs are markdown links to the other spec's `spec.md`: in a spec's `Dependencies` / `Dependents` metadata (relative to the spec folder) and in the **Depends On** column here (relative to the KB root).
- Every spec's `Requirements` metadata links the SRS folder(s) it implements, or `none`. `MODULE-MAP.md` shows the full SRS → plan → specs trace.

## Column definitions

- **Spec ID**: `<PREFIX>-<Module>-NNN` (module spec) or `<PREFIX>-NNN` (cross-cutting), matching the folder in the **Folder** column. IDs are never reused.
- **Module**: the module folder, or `_cross-cutting`.
- **Status**: `Draft` · `Approved` · `Deprecated`. It must match the spec's metadata. Only humans change it.
- **Version**: the spec's semver.
- **Coverage**: `Verified ACs / Total ACs` from the spec's §5 Verification Matrix. The validator prints it.
- **Owner**: the person who approves changes to this spec.
- **Last Updated**: `YYYY-MM-DD` of the last changelog entry.
- **Depends On**: links to the specs this spec consumes (same layer, and for a consumer layer the provider specs too), or `none`. Review these, and the spec's `Dependents`, when making a breaking change.
- **Folder**: path of the spec folder, relative to the KB root. Must stay the 9th column (the validator reads it).

Keep deprecated specs in the table with Status `Deprecated`, and name the replacement in their changelog.
