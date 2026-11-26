---
name: intake-requirement
description: Take a new requirement (PRD, CR, meeting note, mock-up) dropped into $KB/<Module>/PRD/, file it as REQ-<Module>-NNN (if no other layer has), write or extend its plan with this layer's impact and the contracts it needs or changes, record the trace in MODULE-MAP, and — after the plan is approved — hand off to spec drafting for this layer.
---

# Skill: intake-requirement

> Sessions started in the KB use `$KB/.ai/skills/plan-requirement` instead: it plans every layer at once. This skill is its single-layer equivalent. Both end with an approved plan in `$KB/<Module>/Planning/` before any spec is drafted.

**Use when:** a human says a new requirement has arrived, `bash .ai/scripts/validate-specs.sh` warns `unfiled requirement` for a file in `$KB/<Module>/PRD/`, or `$KB/MODULE-MAP.md` lists planned specs of this layer for a requirement that has none yet.
`$KB`, `<Layer>`, `<PREFIX>`, `<INDEX>`, `Consumes`: `.ai/ai.md` → intro.

Agents **never edit the requirement documents**. They only file them, describe them in a `README.md`, plan and trace them.

## Steps

1. **Locate the requirement.**
   - Loose files in `$KB/<Module>/PRD/` (not inside an `NNN-slug/` folder) are new. So is an `NNN-slug/` folder without a `README.md`.
   - Already filed (`$KB/<Module>/PRD/NNN-slug/README.md` exists, maybe by another layer)? Read it, its plan and its `$KB/MODULE-MAP.md` row, then go to step 4.
   - If the human pasted or described the requirement instead, ask them to save it into `$KB/<Module>/PRD/` first. Don't write requirement text yourself.
   - Read every document in full, including images, mock-ups and attachments you can read.
2. **Pick the owning module:** the module whose business area the request is about (where a product owner would look for it). It may drive specs in other modules and layers; that goes in the plan's §4, not by moving the requirement. Cross-cutting requests (no single module) go to `$KB/_cross-cutting/PRD/`. If unsure, ask.
3. **File it** (only if not filed yet).
   - Next number: the highest `NNN` among `$KB/<Module>/PRD/[0-9][0-9][0-9]-*/`, plus 1; `001` if none. Never reuse a number.
   - Create `$KB/<Module>/PRD/NNN-slug/` (kebab-case slug, not repeating the module name) and **move** the loose documents into it unchanged (same file names) with `mv` / `git mv`: filing is the only change the policy allows to requirement documents; never copy, rewrite or convert them. A folder the human already created keeps its name. Remove `$KB/<Module>/PRD/.gitkeep` if present.
   - Create `README.md` from `$KB/_kb/templates/requirement-template.md`: ID `REQ-<Module>-NNN` (or `REQ-NNN` for cross-cutting), title, source (work item / ticket number: ask if the documents don't say), received date, owner, the Documents table, and a 2–5 sentence summary taken from the documents.
4. **Plan it.** Create or extend the plan `$KB/<Module>/Planning/NNN-slug/plan.md` (same `NNN-slug` as the PRD folder; template `$KB/.ai/templates/plan-template.md`; Status `Draft`, never set `Approved`; remove `$KB/<Module>/Planning/.gitkeep`). Fill or extend, grounded in this repo's code (`src/`) and the specs (`$KB/<INDEX>` and the other layers' indexes), never in guesses:
   - §1 understanding and scope; §2 exploration findings (each with a path or spec ID); §3 approach (decisions with the rejected alternative).
   - §4 impact, one row per spec to draft or amend (one spec per module and layer):

     | Layer | Module | Amend existing / new spec | What changes | Contract (endpoint / message / screen) | Depends on |
     |---|---|---|---|---|---|
     | backend | Billing | amend SPEC-Billing-001 | … | additive field on `GET /v2/invoices` | — |
     | frontend | Billing | new FE-Billing-NNN | … | invoice list screen | the backend row above |

     - **Provider layers:** flag every §3 change a consuming layer will use.
     - **Consumer layers:** every contract the feature needs must be found in a provider spec §3 (say whether it exists and is `Approved`). Anything missing is a **provider** row: the provider repo drafts it; this layer waits.
   - §5 work breakdown: tasks `T-NN`, each a small piece of behaviour built end to end, with its per-layer (planned) specs and ACs and **Depends on**; status `Open` (rules in the template comment). If another layer already wrote §5, add this layer's part to its tasks instead of adding layer-only ones.
   - §6 questions for the product owner: every gap, ambiguity or conflict, with why it matters and a proposed answer, asked in rounds and with terms checked against `$KB/GLOSSARY.md` (`$KB/.ai/skills/plan-requirement` → *Asking the questions*, *Terms and decisions*). §7 risks and assumptions.
   - If the plan already exists (another layer wrote it), add this layer's rows and questions; bump the plan's Version and add a §8 Revisions row.
5. **Record the trace.** In `$KB/MODULE-MAP.md` → *Traceability*: add the row if the requirement is new, otherwise update it: requirement link, title, Plan link, the planned specs of this layer in its column (existing ones as links; planned new ones as plain text, e.g. `new: SPEC-Billing-NNN (invoice export)`), Trace status `Planning` (or keep a later status), and a note on what other layers need. Add the requirement ID to its module's row in *Modules*.
6. **Validate:** `bash .ai/scripts/validate-specs.sh` exits 0 and no longer warns about these files.
7. **Gate: confirm with the human** before drafting anything: the module choice, the plan (impact table, work breakdown), the questions for the product owner (ready to paste), and any work another layer must do first. Wait until the human sets the plan to `Approved`. When answers arrive, record each in plan §6 (who, date), update the plan (bump Version, §8 row) and ask again.
8. **Draft this layer's specs** (plan `Approved`; consumer layers: only those whose provider contracts exist, Approved or at least drafted): for each row of this layer, amend the existing spec (`spec-architect` persona, version bump, changelog entry, `Requirements` row extended, and in a consumer layer the `<ProviderLayer> Specs` row) or run `new-spec`. Write the real spec IDs into the plan's §4 and §5; replace the planned IDs in `$KB/MODULE-MAP.md` with links, and set Trace status `Specifying`.
9. **Hand off the other layers:** leave their rows in `$KB/MODULE-MAP.md` as planned, and tell the human to run `intake-requirement` in that layer's repo (or `implement-requirement` from the KB), listing exactly which contracts are needed or changed.
10. **Validate** again, then **report:** REQ ID and folder, plan path and version, specs created or amended, open questions, and the work left for other layers. Stop for human approval of the specs.
