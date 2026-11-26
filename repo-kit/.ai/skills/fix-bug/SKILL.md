---
name: fix-bug
description: Find and fix a bug, flaky test or performance regression in this repo — reproduce it reliably first, narrow it, test hypotheses one at a time, then fix behind a regression test traced to a spec AC.
---

# Skill: fix-bug

**Use when:** the code behaves wrongly, throws, flakes or got slower. Environment problems (setup, tools, config) go to `troubleshoot`. Personas: `test-engineer.md` for the reproduction and regression test, `core-engineer.md` for the fix. Check `$KB/.ai/memory/` `fix-` entries of this layer first.

Redact secrets (`<REDACTED>`) in every command, output and log you show.

| Phase | Do | Done when |
|---|---|---|
| 1. Reproduce | Build one command that shows the reported symptom: preferably a failing test at a spec §5 test entry point; otherwise a script, HTTP call, browser script, replayed request, or `git bisect run` between a good and a bad state. Make it fast and deterministic (pin time, seed randomness, isolate network). For a flaky bug, raise the failure rate until it is workable. | The command has been run, shows the human's exact symptom, gives the same verdict every run, and takes seconds. Without it, stop and ask the human for an environment, a redacted log or permission to instrument. Theories wait until this exists. |
| 2. Narrow | Remove inputs, data, config and steps one at a time, re-running after each. | Every remaining element is needed for the failure. |
| 3. Hypothesise | List 3–5 ranked causes, each with a prediction that would prove it wrong. Share the list with the human. | Each hypothesis is testable. |
| 4. Instrument | Test one prediction at a time: debugger first, otherwise a few logs carrying one unique tag (e.g. `[DEBUG-a4f2]`). For slowness, measure a baseline and bisect instead of logging. | One hypothesis is confirmed. |
| 5. Fix | Find the AC the bug breaks; none means a spec gap (Open Question / `sync-spec`, ask the human first). Turn the narrowed repro into a failing test tagged `<SPEC-ID>-AC-NN` at a test entry point that really replays the bug (if none exists, report that as an architecture finding), fix, see it pass, re-run the phase 1 command. Then rule 00 steps 4–5 with a `fix` changelog row naming the root cause. | Regression test and original repro both green; DoD met. |
| 6. Clean up | Remove tagged logs and throwaway scripts; put the confirmed cause in the suggested commit body (rule 03); offer a `fix-` memory entry, and what would have caught it earlier to `$KB/.ai/skills/improve-workflow`. | Nothing temporary left behind. |
