# PreToolUse hook enforcing .ai/hooks/policy.md for Claude Code.
# Rules are parsed from policy.md at runtime, so edits to the policy take effect without changing this script.
# Exit 2 = block (stderr is shown to Claude). JSON on stdout with permissionDecision "ask" = require approval.
# Launched by .claude/settings.json with pwsh (PowerShell 7) if installed, else Windows PowerShell 5.1.
# Keep this file ASCII-only: Windows PowerShell 5.1 reads a script without a BOM as ANSI, which garbles non-ASCII text.
$ErrorActionPreference = 'Stop'
[Console]::InputEncoding = [Text.Encoding]::UTF8
[Console]::OutputEncoding = [Text.Encoding]::UTF8

function Block([string]$msg) { [Console]::Error.WriteLine("Blocked by .ai/hooks/policy.md: $msg"); exit 2 }

try {
    $payload = [Console]::In.ReadToEnd() | ConvertFrom-Json
} catch { Block "hook could not parse its input ($_)" }

$root = if ($env:CLAUDE_PROJECT_DIR) { $env:CLAUDE_PROJECT_DIR } else { $payload.cwd }
$policyPath = Join-Path $root '.ai/hooks/policy.md'
if (-not (Test-Path $policyPath)) { Block "policy file not found at $policyPath" }

# Parse "## <section>" blocks and their "- **id** <em dash> ``regex`` <em dash> reason" / "- `glob`" lines.
$sections = @{}
$current = $null
foreach ($line in Get-Content -LiteralPath $policyPath -Encoding UTF8) {
    if ($line -match '^## (.+)$') { $current = $Matches[1].Trim(); $sections[$current] = @(); continue }
    if (-not $current) { continue }
    if ($line -match '^- \*\*(?<id>[^*]+)\*\* \p{Pd} ``(?<re>.+?)`` \p{Pd} (?<reason>.*)$') {
        $sections[$current] += [pscustomobject]@{ Id = $Matches.id; Regex = $Matches.re; Reason = $Matches.reason }
    } elseif ($line -match '^- `(?<glob>[^`]+)`\s*$') {
        $sections[$current] += [pscustomobject]@{ Glob = $Matches.glob }
    }
}
$shellDeny = $sections['Shell: deny']
$shellAsk = $sections['Shell: ask']
if (-not $shellDeny) { Block 'no Shell: deny rules parsed from policy.md' }

function Test-Rules($rules, [string]$text) {
    foreach ($r in $rules) {
        if ($r.Regex -and [regex]::IsMatch($text, $r.Regex, 'IgnoreCase')) { return $r }
    }
    return $null
}

# Glob -> regex: ** = any depth, * = within one folder, no "/" = file name anywhere.
function Test-Glob([string]$rel, [string]$glob) {
    $g = $glob
    $anywhere = -not $g.Contains('/')
    $re = [regex]::Escape($g) -replace '\\\*\\\*/', '(?:.*/)?' -replace '/\\\*\\\*', '(?:/.*)?' -replace '\\\*\\\*', '.*' -replace '\\\*', '[^/]*' -replace '\\\?', '[^/]'
    if ($anywhere) { $re = '(?:^|/)' + $re + '$' } else { $re = '^' + $re + '$' }
    return [regex]::IsMatch($rel, $re, 'IgnoreCase')
}
function Test-GlobList($entries, [string]$rel) {
    $hit = $false
    foreach ($e in $entries) {
        if (-not $e.Glob) { continue }
        if ($e.Glob.StartsWith('!')) { if (Test-Glob $rel $e.Glob.Substring(1)) { $hit = $false } }
        elseif (Test-Glob $rel $e.Glob) { $hit = $true }
    }
    return $hit
}

$tool = $payload.tool_name
$in = $payload.tool_input

if ($tool -eq 'Bash' -or $tool -eq 'PowerShell') {
    $cmd = [string]$in.command
    $r = Test-Rules $shellDeny $cmd
    if ($r) { Block "$($r.Id) - $($r.Reason)" }
    $r = Test-Rules $shellAsk $cmd
    if ($r) {
        @{ hookSpecificOutput = @{ hookEventName = 'PreToolUse'; permissionDecision = 'ask'; permissionDecisionReason = "policy.md $($r.Id): $($r.Reason)" } } |
            ConvertTo-Json -Depth 5 -Compress
        exit 0
    }
    exit 0
}

if ($tool -in @('Edit', 'Write', 'MultiEdit', 'NotebookEdit', 'Read')) {
    $path = [string]$(if ($in.file_path) { $in.file_path } else { $in.notebook_path })
    if (-not $path) { exit 0 }
    $full = [IO.Path]::GetFullPath($(if ([IO.Path]::IsPathRooted($path)) { $path } else { Join-Path $root $path }))
    $rootFull = [IO.Path]::GetFullPath($root).TrimEnd('\', '/')
    $rel = if ($full.StartsWith($rootFull, [StringComparison]::OrdinalIgnoreCase)) { $full.Substring($rootFull.Length).TrimStart('\', '/') } else { $full }
    $rel = $rel -replace '\\', '/'

    if (Test-GlobList $sections['Files: deny read'] $rel) { Block "$rel is a secrets file (Files: deny read)" }
    if ($tool -eq 'Read') { exit 0 }

    if (Test-GlobList $sections['Files: protect'] $rel) { Block "$rel is protected (Files: protect); a human edits it" }
    if ((Test-GlobList $sections['Files: no modify existing'] $rel) -and (Test-Path -LiteralPath $full)) {
        Block "$rel already exists (Files: no modify existing); add a new migration instead"
    }

    $content = @($in.content, $in.new_string, $in.new_source) + @($in.edits | ForEach-Object { $_.new_string }) -join "`n"
    $r = Test-Rules $sections['Content: deny'] $content
    if ($r) { Block "content matches $($r.Id) - $($r.Reason)" }
}
exit 0
