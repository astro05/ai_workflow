# Decision records

Decisions that outlive a single spec and bind every layer. One file per decision: `NNN-slug.md`, ID `DEC-NNN` (next number = highest + 1, never reused). A spec's own choices stay in its §2.4, a plan's in its §3, and choices fixed by a repo's `.ai/project/` need no record.

**Write one only when** the decision is costly to reverse, would puzzle a later reader without its context, and was chosen over real alternatives: the shape of the system, how modules or layers integrate, a technology that locks us in, data ownership, a deliberate deviation from a convention.

## Format

```markdown
# DEC-NNN: <Decision>

| Field | Value |
|---|---|
| Status | Draft |
| Created | YYYY-MM-DD |
| Requirements / Specs | REQ-… / <SPEC-ID> |
| Replaced by | <DEC-NNN, only when Deprecated> |

<Context, decision and reason, in a few sentences. Add rejected options or consequences only if worth remembering.>
```

> Status lifecycle, as for specs: `Draft → Approved → Deprecated`. Agents draft (`Draft`) and link the record from plan §3 or spec §2.4; only humans change Status. An `Approved` record is never edited: a change of mind is a new record, and the old one becomes `Deprecated` with `Replaced by`.

## Index

| ID | Decision | Status |
|---|---|---|
| <none yet> | | |
