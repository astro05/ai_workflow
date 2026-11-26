# .ai/hooks

[`policy.md`](policy.md) lists what AI agents may never do in this repo: shell commands that are denied or need approval, protected and secret files, forbidden content, and spec rules.

## How it works

1. **A human** writes the rules in `policy.md`, keeping the formats described at its top.
2. **The agent**, on its first session (`ai.md` §0) or after `policy.md` changes, follows *Applying this policy* in `policy.md`:
   - it maps each section to its tool's native permission rules or hooks;
   - shows you the exact config diff and waits for your approval;
   - reports which rules the tool enforces and which the agent follows manually.
3. **The agent obeys the whole policy** even where its tool can't enforce it.

## Claude Code

The kit ships `.claude/settings.json` (deny / ask permission rules) and `.claude/hooks/policy-guard.ps1`, a `PreToolUse` hook that parses `policy.md` at runtime and blocks or asks accordingly. Edits to `policy.md` take effect without touching the script.
- The hook command runs `pwsh` (PowerShell 7) if installed, otherwise Windows PowerShell. macOS/Linux: install PowerShell 7. With no PowerShell at all, the hook blocks every tool call with a message saying so, rather than silently not enforcing the policy.
- Keep `policy-guard.ps1` ASCII-only: Windows PowerShell reads a script without a BOM as ANSI.
- Globs starting with `**/` also match absolute paths outside the repo, so a session started here cannot edit the KB's validator (`_kb/`), policy, tool settings or requirement documents either. The KB has its own policy for sessions started there.
- Reads of secrets are blocked by the native `Read(...)` rules in `.claude/settings.json`, not by the hook (a hook run on every read costs about a second with Windows PowerShell). When you change *Files: deny read*, change those rules too.

## What you should know

- How strong the enforcement is depends on the tool. Tools with permission rules or blocking hooks (e.g. Claude Code, Gemini CLI, Cursor, OpenCode) can enforce most of the policy. Others rely on the agent following it.
- Native permission rules match command prefixes, not regexes, so agents translate each rule conservatively. Check the coverage report the agent gives you.
- The shell rules match the whole command text, including heredocs and quoted strings: a file whose content mentions a denied command has to be written with the editor tool, not the shell.
- File protection covers the editor tools (by path) and the shell (rules `shell-write-protected`, `shell-copy-into-protected`, `shell-edit-requirements`). The shell rules recognise the usual ways to write, copy, move or delete a file; a determined script can still get around a pattern match, so treat them as guard rails, not a sandbox.
- The backstop that catches every tool: CI running `bash .ai/scripts/validate-specs.sh`, plus branch protection on your git host, so no agent can push to or merge into the main branch.
- After you edit `policy.md`, tell the agent: `policy.md changed. Re-apply it to your tool's settings.`
