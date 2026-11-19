# .ai/hooks

[`policy.md`](policy.md) lists what AI agents may never do from this knowledge base: shell commands that are denied or need approval, protected and secret files, forbidden content, and spec rules. Each product repo has its own `.ai/hooks/policy.md`; agents obey the stricter of the two.

## How it works

1. **A human** writes the rules in `policy.md`, keeping the formats described at its top.
2. **Claude Code** enforces it out of the box: `.claude/settings.json` holds native permission rules, and `.claude/hooks/policy-guard.ps1` (a PreToolUse hook) parses `policy.md` at runtime, so edits to the policy apply without touching the script. The hook runs `pwsh` (PowerShell 7) if installed, otherwise Windows PowerShell; on macOS/Linux install PowerShell 7. With no PowerShell at all, it blocks every tool call with a message saying so, rather than silently not enforcing the policy. Keep `policy-guard.ps1` ASCII-only: Windows PowerShell reads a script without a BOM as ANSI.
3. **Other tools:** on the first session (`.ai/ai.md` §0) or after `policy.md` changes, the agent follows *Applying this policy* in `policy.md`:
   - it maps each section to its tool's native permission rules or hooks;
   - shows you the exact config diff and waits for your approval;
   - reports which rules the tool enforces and which the agent follows manually.
4. **The agent obeys the whole policy** even where its tool can't enforce it, and never works around a block.

## What you should know

- How strong the enforcement is depends on the tool. Tools with permission rules or blocking hooks (e.g. Claude Code, Gemini CLI, Cursor, OpenCode) can enforce most of the policy. Others rely on the agent following it.
- Native permission rules match command prefixes, not regexes, so agents translate each rule conservatively. Check the coverage report the agent gives you.
- Globs starting with `**/` also match absolute paths, so the hook protects the repos' policies and settings too, and any other folder with the same layout (including copies of this kit). A human installs or edits those files.
- The shell rules match the whole command text, including heredocs and quoted strings: a file whose content mentions a denied command has to be written with the editor tool, not the shell.
- The backstop that catches every tool: CI running the validators, plus branch protection on your git host, so no agent can push to or merge into the main branch.
- After you edit `policy.md`, tell the agent: `policy.md changed. Re-apply it to your tool's settings.`
