---
name: review-change
description: Review a diff against this repo's standards and against its owning spec, as two separate passes reported side by side. Read-only; fixes follow through the developer loop.
---

# Skill: review-change

**Use when:** rule 00 loop step 4, before a plan §5 task is reported done, at close-out, or when a human asks for a review. Security-sensitive changes also get `security-auditor.md`; contract shape stays with `verify-contract`.

## Steps

1. **Scope.** The base is what the human names, else the merge-base with the integration branch (`.ai/project/commit-conventions.md`). Confirm the diff is non-empty (committed and uncommitted changes).
2. **Inputs.**
   - *Standards:* `.ai/project/`, rules 01–02, `$KB/.ai/memory/` entries for this layer, `$KB/GLOSSARY.md`.
   - *Spec:* the owning spec(s) (from `Refs:` footers or §2.1 ownership), the ACs in scope, and in a consumer layer the provider specs' §3. Changed code with no owning spec is an orphan finding.
3. **Two passes, kept apart.** Run the Standards pass and the Spec pass separately (two read-only subagents with an empty context if the tool has them, rule 00 invariant 11; otherwise one after the other, writing each down before starting the next), so one doesn't colour the other.
   - **Standards:** breaches of a documented rule (cite file and rule) are hard findings. Design smells (unclear or non-glossary names, duplication, logic living away from its data, primitives standing in for domain concepts, speculative abstraction, pass-through layers, one change scattered across many files) are judgement calls, and a documented rule overrides them. Skip what the linter enforces.
   - **Spec:** ACs, §3 contracts, §4 error codes or invariants missing or wrong; behaviour nobody specified; tests outside the agreed §5 test entry points or untagged. Quote the spec line.
4. **Report** under `## Standards` and `## Spec`, without merging or re-ranking across them, plus one summary line: count and worst finding per pass.
5. **Act:** hard findings go back through the loop (a spec finding may mean an Open Question for the human); judgement calls go to the human with a recommendation; a recurring mechanical finding is a candidate for an automated check (`$KB/.ai/skills/improve-workflow`).
