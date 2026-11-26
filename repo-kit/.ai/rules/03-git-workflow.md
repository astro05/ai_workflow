# 03 — Git Workflow

## Branches
Use the team's branch convention, recorded in `.ai/project/commit-conventions.md` → *Branches*. Agents don't create, switch, or delete branches unless the human asks; the human names the branch for each piece of work.

## Commits — exactly as in `.ai/project/commit-conventions.md`
`.ai/project/commit-conventions.md` is authoritative: types, scope, body, footers, and breaking-change marking.

SDD adds one thing, using the standard `Refs:` footer:

```
feat(billing): reject invoices with zero quantity

<why, not what>

Refs: SPEC-Billing-002 AC-02, AC-03
```

- Every `feat` or `fix` commit that implements spec'd behavior has a `Refs:` footer naming the spec and ACs.
- Specs are not in this repo: they live in `$KB`, which is its own git repo. Commits there use type `docs` with a scope for the kind of change: `docs(prd)`, `docs(plan)`, `docs(specs)`, `docs(map)`, `docs(memory)`, e.g. `docs(specs): draft SPEC-Billing-002 for invoice export`. Never mix KB and code changes in one commit.
- A breaking §3 contract change uses `!` and/or a `BREAKING CHANGE:` footer with migration notes.
- A bug-fix commit body names the confirmed root cause (`.ai/skills/fix-bug`).
- Commit only when the human asks.

## Pull requests
1. **Plan and spec first.** A behavior change starts with its plan and spec change in `$KB`, reviewed and set to `Status: Approved` by a human, **then** the implementation. Small amendments may go together with the code only if the spec diff is reviewed first.
2. Each PR description includes: the owning spec(s) with their version and ACs covered, a "Spec drift: none / described" line, a short sketch of the change (call flow, file tree or diagram, whichever is smallest), before/after evidence (test output, or screenshots for UI), and the risk: whether it can be rolled back (a breaking §3 change or destructive migration cannot) and what it could affect. (Whether requirement IDs appear too is a team choice; check `$KB/.ai/memory/`.)
3. CI must pass. Run the Definition of Done (rule 02) locally before opening the PR.
4. Changes to auth, secrets, PII, or input parsing need a `security-auditor` review.
5. Merging is done by humans.

## Spec versioning
- Semver in the spec's metadata `Version`: MAJOR = breaking contract, MINOR = additive behavior, PATCH = clarification, typo, or implementation-only change.
- Every version bump gets a `changelog.md` entry. Never rewrite past changelog entries. Fix mistakes with new entries.
- A spec never gets deleted. Set its status to `Deprecated` (a human does), and record its replacement in `$KB/<INDEX>`, the changelog, and `$KB/MODULE-MAP.md`.

## Never
- Push, force-push, or rewrite history (`.ai/hooks/policy.md`).
- Bring the integration branch into a work branch (pull, merge, rebase) unless the human asks; resolve conflicts on the branch's own side.
- Commit secrets, credentials, or generated artifacts (build output, dependencies).
- Bypass hooks or CI (`--no-verify`).
