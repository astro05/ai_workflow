---
name: plan-requirement
description: Take a requirement the human dropped into <Module>/PRD/, file it as REQ-<Module>-NNN, explore every layer's repo, and write its plan in <Module>/Planning/NNN-slug/plan.md (understanding, findings, approach, impact per layer, work breakdown, questions for the product owner). Stage 2 of the delivery flow; ends at the plan approval gate.
---

# Skill: plan-requirement

**Use when:** new files appear in `<Module>/PRD/` (`bash _kb/scripts/validate-kb.sh` warns `unfiled requirement`), an `PRD/NNN-slug/` folder has no `README.md` or no plan yet, or the human says "plan this requirement". Phase 1 of `implement-requirement`. Layers and `$REPO[<layer>]`: `.ai/ai.md` → *Paths*.

Never edit the requirement documents. File them, describe them, plan them. Write no spec and no code in this skill.

## A. File the requirement (PRD)

1. **Locate and read.** Read every document in full (a `.docx`/`.pdf` through a text twin or extraction if your tool can't read it directly; mock-ups and screenshots too). If the human only described the requirement, ask them to save it in `<Module>/PRD/` first; don't write requirement text yourself.
2. **Owning module:** the business module the request is about (where a product owner would look for it); `_cross-cutting` if none. It may drive specs in other modules; that goes in the plan's §4. If unsure, ask.
3. **File it** (skip if `PRD/NNN-slug/README.md` already exists). Next number = highest `NNN` in `<Module>/PRD/[0-9][0-9][0-9]-*/` + 1 (`001` if none; never reuse). Create `<Module>/PRD/NNN-slug/` (kebab-case slug, not repeating the module name), move loose files into it unchanged with `mv` / `git mv` (filing is the only change the policy allows to requirement documents; never copy, rewrite or convert them), remove `<Module>/PRD/.gitkeep`. A folder the human already created keeps its name. Write `README.md` from `_kb/templates/requirement-template.md` (ID `REQ-<Module>-NNN`, or `REQ-NNN` in `_cross-cutting`; title, source: ask for the work item number if missing; received date, owner, Documents table, summary).

## B. Explore

4. **Ground everything in code and specs, never in guesses.** For each layer in `_kb/kb.conf`, load `$REPO/.ai/project/*` for orientation, then:
   - search `$REPO`'s source root (the layer index → *Project paths*) for the code involved: endpoints, services, entities, tables, messages, screens, routes;
   - check the layer's index and `MODULE-MAP.md` for specs that already own them, and read their §2–§3;
   - for a consumer layer, note every provider contract it would need and whether an `Approved` provider spec §3 already has it.
   - External systems, data sources or libraries the documents name: what they are and what using them would need (a new package is a §2.4 decision in the spec later; list it here as a decision).
   Use read-only search only. No builds, no installs.
   - Broad searches may be delegated to read-only subagents (rule 00, invariant 14).
5. **Memory and language:** check `.ai/memory/README.md` for entries that touch this area and apply them to the approach. Read `GLOSSARY.md` and the decision records in `_decisions/` that touch this area; the plan uses the glossary's terms, and respects the decision records (or names the one it proposes to replace).

## C. Write the plan (Planning)

6. Create `<Module>/Planning/NNN-slug/plan.md` (same `NNN-slug` as the PRD folder) from `.ai/templates/plan-template.md`. Remove `<Module>/Planning/.gitkeep`. Fill it in:
   - **§1 Understanding**: the request in our words; explicit in/out of scope.
   - **§2 Exploration findings**: what exists today, each row with a path or spec ID.
   - **§3 Approach**: the design decisions, each with the alternative rejected and why. Apply *Terms and decisions* below.
   - **§4 Impact**: one row per spec to draft in `Implementation/` (one spec per module and layer; amend an existing spec when one owns the behaviour). Every consumer row names the provider contract it needs and whether it exists.
   - **§5 Work breakdown**: tasks `T-01…`, each one small, testable piece of user-visible behaviour built through all the layers it needs, with the tasks it waits for (**Depends on**). Preparatory refactoring comes first (see the template's comment). Status `Open`.
   - **§6 Questions for the product owner**: every gap, ambiguity or conflict in the documents, with why it matters and our proposed answer. See *Asking the questions* below.
   - **§7 Risks and assumptions.**
   - Status `Draft`. Never set `Approved`.
7. **Trace.** Add a row to `MODULE-MAP.md` → *Traceability*: requirement link, title, Plan link, planned specs per layer as plain text (e.g. `new: SPEC-Billing-002 (invoice export)`), Trace status `Planning`. Add the requirement ID to its module's row in *Modules*.
8. **Validate:** `bash _kb/scripts/validate-kb.sh` exits 0 and no longer warns about these files.

## D. Gate

9. **Report and wait.** Give the human: REQ ID and folder, plan path, a one-paragraph approach, the impact table, the work breakdown, and round 1 of the questions for the product owner (ready to paste to them). Ask which branch to use in each repo, and ask the human to check the breakdown: task size, the Depends-on links, anything to merge or split.
10. **Iterate.** When answers come back, record each in §6 (who, date), prepare the next round, update the plan (bump Version, add a §8 Revisions row), and repeat until §6 has no open question in any round and the human sets `Status: Approved`. Then set the map row's Trace status to `Specifying` and continue with phase 2 of `implement-requirement`.

---

## Asking the questions (§6)

- **Ask in rounds.** A round contains every question that can be answered now; a question whose answer depends on another open one waits for the next round. After each round, record the answers and work out the next.
- **Always propose.** Each question carries our recommended answer, phrased so the owner can confirm with a "yes".
- **Look up facts, ask for decisions.** Anything the code, specs or documents can answer is found by us (a read-only subagent may help), never asked.
- **Finished** when no open question is left and nothing was decided by assumption.

## Terms and decisions

- Check every business term in the documents and answers against `GLOSSARY.md`. A conflicting, vague or double-meaning word becomes a question; an invented edge-case scenario is often the quickest way to pin its meaning down. Where the documents describe today's behaviour, confirm it in the code.
- Record each settled term in `GLOSSARY.md` in the same change, and list it in plan §3.
- A decision that binds more than this requirement and would be costly to undo is drafted as a `Draft` decision record (`_decisions/README.md`); everything else stays in plan §3 and later spec §2.4.
