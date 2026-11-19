---
name: new-spec
description: Scaffold a new spec of this layer in the KB inside its module folder (module-wise numbering), link it to its requirement, the specs it depends on and (consumer layers) the provider specs it consumes, register it in the layer's index and MODULE-MAP, and hand off to the spec-architect persona.
---

# Skill: new-spec

**Use when:** a request needs behavior that no existing spec of this layer owns (check `$KB/<INDEX>` and `$KB/MODULE-MAP.md` first; if a spec already owns it, amend that spec instead). If the request arrived as an SRS document, run `intake-requirement` first; its plan must be `Approved`.

`$KB`, `<Layer>`, `<PREFIX>`, `<INDEX>`, `Consumes`: `.ai/ai.md` → intro. Specs are created **module-wise**: `$KB/<Module>/Implementation/<Layer>/NNN-slug/`, with ID `<PREFIX>-<Module>-NNN` and `NNN` numbered **per module and per layer**.

Example (backend layer, prefix `SPEC`): the first Billing spec is `$KB/Billing/Implementation/Backend/001-invoice-export/` = `SPEC-Billing-001`; the next is `…/002-<slug>/` = `SPEC-Billing-002`.

## Steps

1. **Pick the module:** the module whose code the spec changes, spelled exactly as its folder in `$KB` (the module list in `.ai/project/overview.md`).
   - A change that spans several modules gets **one spec per module**. The module that owns the shared contract or storage gets its own spec; the others depend on it (step 6).
   - A UI screen that mixes modules belongs to the module that owns the main record; list the other modules' provider specs in `<ProviderLayer> Specs`.
   - A spec that belongs to no single module (a baseline such as `<PREFIX>-001`) goes under `$KB/_cross-cutting/Implementation/<Layer>/NNN-slug/` with ID `<PREFIX>-NNN`. Use this only when no module fits, and say why in the spec.
   - If the module has no folder in `$KB` yet, and it exists in this repo, create `$KB/<Module>/{SRS,Planning,Implementation/<Layer>}/` with that exact name (each with a `.gitkeep`) and add the module to *Modules* in `$KB/MODULE-MAP.md`. If it doesn't exist in any repo, stop and ask.
2. **Pick the next number in that module and layer:** the highest `NNN` among `$KB/<Module>/Implementation/<Layer>/[0-9][0-9][0-9]-*/`, plus 1; `001` if none. Never reuse a number, including those of deprecated specs.
   ```bash
   . .ai/kb.conf; KB="${SDD_KB:-$KB}"
   ls -d "$KB"/<Module>/Implementation/<Layer>/[0-9][0-9][0-9]-*/ 2>/dev/null | xargs -n1 basename | cut -c1-3 | sort -n | tail -1
   ```
3. **Pick a slug:** a short kebab-case name for the feature or screen. Do **not** repeat the module name (the folder already says it). Code paths follow `.ai/project/` and are listed in spec §2.1.
4. **Create the folder:**
   ```bash
   mkdir -p "$KB"/<Module>/Implementation/<Layer>/NNN-slug
   cp .ai/templates/spec-template.md "$KB"/<Module>/Implementation/<Layer>/NNN-slug/spec.md
   rm -f "$KB"/<Module>/Implementation/<Layer>/.gitkeep
   ```
5. **Fill the metadata:** `ID: <PREFIX>-<Module>-NNN`, Title, `Status: Draft`, `Version: 0.1.0`, Author, Owner, and today's date for Created and Last Updated. The heading is `# <PREFIX>-<Module>-NNN: <Title>`. Remove the `<ProviderLayer> Specs` row in a provider layer; keep and rename it (e.g. `Backend Specs`) in a consumer layer.
6. **Link** (all links relative to the new spec folder; every spec folder is four levels below `$KB`, so links start with `../../../../`):
   - `Requirements`: each requirement folder this spec implements, e.g. `[REQ-Billing-001](../../../../Billing/SRS/001-invoice-export/)`. Use `none` only for a baseline or a purely technical spec, and say why in §1.1.
   - `Dependencies`: each spec **of this layer** this one builds on, e.g. `[SPEC-001](../../../../_cross-cutting/Implementation/Backend/001-core-system/spec.md)`, or `none`.
   - **Consumer layers:** `<ProviderLayer> Specs`: each provider spec whose §3 this spec consumes, e.g. `[SPEC-Billing-001](../../../../Billing/Implementation/Backend/001-invoice-export/spec.md)`, or `none` for a purely client-side change. Provider specs are **not** edited from here.
   - `Dependents`: `none` for a new spec. For **each** dependency of this layer, add a link back to the new spec in that spec's `Dependents` row (replace `none`), and a changelog entry there (PATCH bump: "Dependents: added <new ID>").
   - Reference other specs in the body by ID (`SPEC-Billing-001 INV-04`); the metadata links are the navigation.
7. **Create `changelog.md`** in the folder:
   ```markdown
   # <PREFIX>-<Module>-NNN Changelog

   | Date | Version | Type | Change | ACs | Ref |
   |---|---|---|---|---|---|
   | YYYY-MM-DD | 0.1.0 | created | Initial draft | — | — |
   ```
8. **Register the spec:**
   - `$KB/<INDEX>`: add a row: Spec ID, Module, Status `Draft`, Version `0.1.0`, Coverage `0/N`, Owner, Last Updated, Depends On (this layer's dependencies **and**, in a consumer layer, the provider specs, as links relative to `$KB`), Folder `` `<Module>/Implementation/<Layer>/NNN-slug/` ``. Keep rows of one module together.
   - `$KB/MODULE-MAP.md`: add the spec to its module's row in *Modules*, and to this layer's specs cell of each requirement it implements in *Traceability* (link relative to `$KB`, replacing any `new: …` placeholder). Set the requirement's Trace status to `Specifying`. A spec with `Requirements: none` goes in *Specs without a requirement*.
   - The requirement's plan §4 and §5: replace the planned ID with the real one.
9. **Validate:** `bash .ai/scripts/validate-specs.sh` must exit 0 and list the new spec (`INFO <Module>/Implementation/<Layer>/NNN-slug: <ID> …`). It fails on a wrong ID, an unregistered dependency or requirement, a link that does not resolve, or a spec missing from `MODULE-MAP.md`.
10. **Hand off:** follow `.ai/agents/spec-architect.md` to fill in the content. **Stop before implementation.** A human must approve the spec first.
