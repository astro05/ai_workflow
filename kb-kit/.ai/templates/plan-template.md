# Plan: REQ-<Module>-NNN <Title>

<!--
The plan of one requirement: <Module>/Planning/NNN-slug/plan.md, same NNN-slug as <Module>/SRS/NNN-slug/.
Written by the plan-requirement skill (agents). A human sets Status to Approved; until then no spec is drafted.
Ground every finding in code and specs (file paths, spec IDs), never in guesses.
Other notes (exploration dumps, diagrams, product owner replies) may sit next to this file.
-->

## Metadata

| Field | Value |
|---|---|
| Requirement | [REQ-<Module>-NNN](../../SRS/NNN-slug/) |
| Status | Draft |
| Version | 0.1.0 |
| Author | <agent / human> |
| Product owner | <who answers the questions in §6> |
| Last Updated | YYYY-MM-DD |

## 1. Understanding

<!-- What the business wants and why, in our own words (3–6 sentences). Then scope. -->

**In scope**
- …

**Out of scope**
- …

## 2. Exploration findings

<!-- What exists today. Every line names a file, endpoint, screen or spec. -->

| Layer | Area | What exists today | Where |
|---|---|---|---|
| backend | … | … | `src/…`, SPEC-<Module>-NNN |
| frontend | … | … | `<path>/…`, FE-<Module>-NNN |

## 3. Approach

<!-- How we will build it: the main design decisions, each with the alternative we rejected and why. -->

| # | Decision | Rejected alternative | Why |
|---|---|---|---|
| D1 | … | … | … |

## 4. Impact (specs to draft in Implementation/)

<!-- One row per spec (one spec per module and layer; amend the existing spec when one owns the behaviour).
     Layers and ID prefixes as in _kb/kb.conf, providers first. A layer with no row is skipped in phases 2 and 3.
     A consumer row names the provider contract it needs and whether it exists (Approved / Draft / missing). -->

| Layer | Module | Amend existing / new spec | What changes | Contract (endpoint / DTO / message / screen) | Consumes / depends on |
|---|---|---|---|---|---|
| backend | <Module> | amend SPEC-<Module>-NNN / new SPEC-<Module>-NNN (<slug>) | … | `GET /api/…` | — |
| frontend | <Module> | new FE-<Module>-NNN (<slug>) | … | <screen> | the backend row above (missing: new field) |

## 5. Work breakdown

<!-- Actionable items, small enough to review one at a time, in the order we will do them.
     Status: Open · In progress · Done · Dropped. Keep it current during implementation. -->

| Task | Layer | What | Spec / AC | Depends on | Status |
|---|---|---|---|---|---|
| T-01 | backend | … | SPEC-<Module>-NNN AC-01..AC-03 | — | Open |
| T-02 | frontend | … | FE-<Module>-NNN AC-01 | T-01 | Open |

## 6. Questions for the product owner

<!-- Everything the documents don't answer. Ask, don't assume. A plan is approved only when every question
     is answered or explicitly deferred (with who decided). -->

| # | Question | Why it matters | Our proposal | Answer (who, date) |
|---|---|---|---|---|
| Q-01 | … | … | … | <open> |

## 7. Risks and assumptions

| # | Risk / assumption | Impact | Mitigation |
|---|---|---|---|
| R-01 | … | … | … |

## 8. Revisions

| Date | Version | Change |
|---|---|---|
| YYYY-MM-DD | 0.1.0 | Initial plan |
