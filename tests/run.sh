#!/usr/bin/env bash
# Self-tests for the kits: the KB validator (kb-kit/_kb/scripts/validate-kb.sh) and the Claude Code policy hook
# (_staging/*/dot-claude/hooks/policy-guard.ps1 with each kit's policy.md). Not part of either kit.
# Usage: bash tests/run.sh        Exit 1 if any case fails. Hook cases are skipped when no PowerShell is installed.
set -uo pipefail

HERE="$(cd "$(dirname "$0")/.." && pwd)"
T="$(mktemp -d)"
trap 'rm -rf "$T"' EXIT
pass=0; fail=0
ok()  { pass=$((pass + 1)); echo "ok    $1"; }
bad() { fail=$((fail + 1)); echo "FAIL  $1"; [ -z "${2:-}" ] || printf '%s\n' "$2" | sed 's/^/      /'; }

# --- Fixture: a valid KB with one requirement, an Approved plan and an Approved, fully verified backend spec ---------
fixture() { # $1 = target folder; creates $1/ProjectKB and $1/backend
  local root="$1" kb="$1/ProjectKB" spec
  mkdir -p "$kb" "$root/backend/tests"
  cp -r "$HERE/kb-kit/." "$kb/"
  mkdir -p "$kb/Billing/PRD/001-invoice-export" "$kb/Billing/Planning/001-invoice-export" \
           "$kb/Billing/Implementation/Backend/001-invoice-export" "$kb/Billing/Implementation/Frontend"
  cat > "$kb/Billing/PRD/001-invoice-export/README.md" <<'EOF'
# REQ-Billing-001: Invoice export

| Field | Value |
|---|---|
| ID | REQ-Billing-001 |
| Title | Invoice export |
EOF
  echo "Customers want a CSV export of their invoices." > "$kb/Billing/PRD/001-invoice-export/request.txt"
  cat > "$kb/Billing/Planning/001-invoice-export/plan.md" <<'EOF'
# Plan: REQ-Billing-001 Invoice export

| Field | Value |
|---|---|
| Requirement | [REQ-Billing-001](../../PRD/001-invoice-export/) |
| Status | Approved |

## 6. Questions for the product owner

| # | Round | Question | Why it matters | Our proposal | Answer (who, date) |
|---|---|---|---|---|---|
| Q-01 | 1 | CSV or XLSX? | Format | CSV | Yes (Jane, 2026-01-01) |

## 7. Risks and assumptions
EOF
  spec="$kb/Billing/Implementation/Backend/001-invoice-export"
  cat > "$spec/spec.md" <<'EOF'
# SPEC-Billing-001: Invoice export

## Metadata

| Field | Value |
|---|---|
| ID | SPEC-Billing-001 |
| Title | Invoice export |
| Status | Approved |
| Version | 1.0.0 |
| Author | agent |
| Owner | Jane |
| Requirements | [REQ-Billing-001](../../../../Billing/PRD/001-invoice-export/) |
| Dependencies | none |
| Dependents | none |
| Created | 2026-01-01 |
| Last Updated | 2026-01-02 |

## 1. Problem Statement & Motivation

### 1.4 Open Questions
| # | Question | Owner | Resolution |
|---|---|---|---|
| Q1 | CSV or XLSX? | Jane | CSV (2026-01-01) |

### 1.5 Assumptions
- A1: exports stay under 10 MB.

<!-- A guidance comment that still mentions a <placeholder>
     over two lines with <another one> -->

## 2. Architectural Boundaries & Data Flow
The service returns Task<ExportResult> and takes `List<<InvoiceId>>`; a < b holds.

```ts
interface ExportRequest { ids: Array<InvoiceId> } // <not a placeholder in code>
```

## 3. Data Schemas & API Contracts
## 4. Error Modes, Invariants & Edge Cases
## 5. Verification Matrix

| AC ID | Criterion (Given / When / Then) | Covers | Test Reference | Status |
|---|---|---|---|---|
| AC-01 | **Given** an invoice **When** exported **Then** the CSV<br>has a header row | G1 | `tests/ExportTests.cs::Export_writes_header` | Verified |
EOF
  printf '| Date | Version | Type | Change | ACs | Ref |\n|---|---|---|---|---|---|\n| 2026-01-01 | 0.1.0 | created | Initial draft | — | — |\n| 2026-01-02 | 1.0.0 | implemented | Export | AC-01 | uncommitted |\n' > "$spec/changelog.md"
  echo '| SPEC-Billing-001 | Billing | Approved | 1.0.0 | 1/1 | Jane | 2026-01-02 | none | `Billing/Implementation/Backend/001-invoice-export/` |' >> "$kb/BACKEND-SPEC-INDEX.md"
  sed -i 's#^| \[_cross-cutting\](_cross-cutting/) | — | — | — |$#&\n| [Billing](Billing/) | REQ-Billing-001 | SPEC-Billing-001 | — |#' "$kb/MODULE-MAP.md"
  sed -i 's#^|---|---|---|---|---|---|---|$#&\n| [REQ-Billing-001](Billing/PRD/001-invoice-export/) | Invoice export | [plan](Billing/Planning/001-invoice-export/plan.md) | [SPEC-Billing-001](Billing/Implementation/Backend/001-invoice-export/spec.md) | — | Done | |#' "$kb/MODULE-MAP.md"
  printf '[TestCategory("SPEC-Billing-001-AC-01")]\npublic void Export_writes_header() {}\n' > "$root/backend/tests/ExportTests.cs"
}

# validate <case name> <expected: "clean" or an ERROR substring> <mutation commands run inside ProjectKB>
validate() {
  local name="$1" expect="$2" mutate="$3" d out
  d="$T/v$((pass + fail))"; mkdir -p "$d"; fixture "$d"
  (cd "$d/ProjectKB" && eval "$mutate")
  out="$(bash "$d/ProjectKB/_kb/scripts/validate-kb.sh" 2>&1)"
  if [ "$expect" = clean ]; then
    if grep -q '^0 error(s)' <<< "$out"; then ok "validator: $name"; else bad "validator: $name" "$(grep -E '^(ERROR|WARN)' <<< "$out")"; fi
  elif grep -q "^ERROR.*$expect" <<< "$out"; then ok "validator: $name"
  else bad "validator: $name (expected ERROR matching '$expect')" "$(grep -E '^(ERROR|WARN)|error\(s\)' <<< "$out")"; fi
}

SPEC=Billing/Implementation/Backend/001-invoice-export
validate "clean kit" clean 'rm -rf Billing; cp "$HERE/kb-kit/MODULE-MAP.md" "$HERE/kb-kit/BACKEND-SPEC-INDEX.md" .'
validate "valid fixture passes (generics, code, comments, <br> are not placeholders)" clean ':'
validate "duplicate requirement number" "duplicate number.*REQ-Billing-001" \
  'cp -r Billing/PRD/001-invoice-export Billing/PRD/001-other; cp -r Billing/Planning/001-invoice-export Billing/Planning/001-other'
validate "duplicate spec number" "duplicate number.*SPEC-Billing-001" \
  "cp -r $SPEC Billing/Implementation/Backend/001-copy; echo '| SPEC-Billing-001 | Billing | Approved | 1.0.0 | 1/1 | Jane | 2026-01-02 | none | \`Billing/Implementation/Backend/001-copy/\` |' >> BACKEND-SPEC-INDEX.md"
validate "Approved plan with an open question" "unanswered questions.*Q-01" \
  "sed -i 's/Yes (Jane, 2026-01-01)/<open>/' Billing/Planning/001-invoice-export/plan.md"
validate "Approved spec with an open question" "unanswered questions.*Q1" "sed -i 's/CSV (2026-01-01)/open/' $SPEC/spec.md"
validate "Approved spec with a template placeholder" "template <placeholders>" "sed -i 's/exports stay under 10 MB/<assumption>/' $SPEC/spec.md"
validate "Approved spec with TBD" "TBD/TODO" "echo 'Retention: TBD' >> $SPEC/spec.md"
validate "Verified AC whose test file lacks the tag" "no test tagged SPEC-Billing-001-AC-01" \
  "sed -i 's/SPEC-Billing-001-AC-01/SPEC-Billing-001-AC-09/' ../backend/tests/ExportTests.cs"
validate "Verified AC whose test file is missing" "does not exist" "rm ../backend/tests/ExportTests.cs"
validate "version drift between spec and index" "version drift" "sed -i 's/| Approved | 1.0.0 |/| Approved | 0.9.0 |/' BACKEND-SPEC-INDEX.md"
validate "coverage drift between matrix and index" "coverage drift" "sed -i 's/| 1.0.0 | 1\/1 |/| 1.0.0 | 0\/1 |/' BACKEND-SPEC-INDEX.md"
validate "spec version with no changelog row" "no row in changelog" "sed -i '\$d' $SPEC/changelog.md"
validate "status drift between spec and index" "status drift" "sed -i 's/| Billing | Approved |/| Billing | Draft |/' BACKEND-SPEC-INDEX.md"

# --- Policy hook ----------------------------------------------------------------------------------------------------
PS=""
if command -v pwsh >/dev/null 2>&1; then PS=pwsh; elif command -v powershell >/dev/null 2>&1; then PS=powershell; fi
if [ -z "$PS" ]; then
  echo "skip  policy hook cases (no PowerShell)"
else
  H="$T/hook"; mkdir -p "$H"; fixture "$H"
  winpath() { (cd "$1" && { pwd -W 2>/dev/null || pwd; }); }
  KBW="$(winpath "$H/ProjectKB")"; REPOW="$(winpath "$H/backend")"
  for kit in kb-kit:ProjectKB repo-kit:backend; do
    mkdir -p "$H/${kit#*:}/.ai/hooks" "$H/${kit#*:}/.claude/hooks"
    cp "$HERE/_staging/${kit%%:*}/dot-ai/hooks/policy.md" "$H/${kit#*:}/.ai/hooks/"
    cp "$HERE/_staging/${kit%%:*}/dot-claude/hooks/policy-guard.ps1" "$H/${kit#*:}/.claude/hooks/"
  done
  # hook <case> <session: kb|repo> <expected: allow|block> <json payload>
  hook() {
    local name="$1" root code out
    if [ "$2" = kb ]; then root="$KBW"; else root="$REPOW"; fi
    out="$(printf '%s' "$4" | CLAUDE_PROJECT_DIR="$root" "$PS" -NoProfile -ExecutionPolicy Bypass -File "$root/.claude/hooks/policy-guard.ps1" 2>&1)"; code=$?
    case "$3:$code" in
      allow:0|block:2) ok "hook ($2): $name" ;;
      *) bad "hook ($2): $name (expected $3, exit $code)" "$out" ;;
    esac
  }
  sh_() { printf '{"tool_name":"%s","tool_input":{"command":"%s"}}' "$1" "$2"; }
  wr_() { printf '{"tool_name":"Write","tool_input":{"file_path":"%s","content":"x"}}' "$1"; }

  hook "normal source edit"                      repo allow "$(wr_ "$REPOW/src/Invoice.cs")"
  hook "edit own policy"                         repo block "$(wr_ "$REPOW/.ai/hooks/policy.md")"
  hook "edit the KB validator"                   repo block "$(wr_ "$KBW/_kb/scripts/validate-kb.sh")"
  hook "edit the KB policy"                      repo block "$(wr_ "$KBW/.ai/hooks/policy.md")"
  hook "edit a requirement document in the KB"   repo block "$(wr_ "$KBW/Billing/PRD/001-invoice-export/request.txt")"
  hook "write a requirement README in the KB"    repo allow "$(wr_ "$KBW/Billing/PRD/001-invoice-export/README.md")"
  hook "edit a spec in the KB"                   repo allow "$(wr_ "$KBW/$SPEC/spec.md")"
  hook "edit a requirement document"             kb   block "$(wr_ "$KBW/Billing/PRD/001-invoice-export/request.txt")"
  hook "write a requirement README"              kb   allow "$(wr_ "$KBW/Billing/PRD/001-invoice-export/README.md")"
  hook "sibling folder sharing the root prefix"  kb   allow "$(wr_ "${KBW}2/notes.md")"
  hook "run the validator"                       kb   allow "$(sh_ Bash 'bash _kb/scripts/validate-kb.sh --layer backend > /tmp/out.txt')"
  hook "git push"                                repo block "$(sh_ Bash 'git push origin main')"
  hook "shell redirect into own policy"          repo block "$(sh_ Bash 'echo x > .ai/hooks/policy.md')"
  hook "sed -i on the KB validator"              repo block "$(sh_ Bash 'sed -i s/a/b/ ../ProjectKB/_kb/scripts/validate-kb.sh')"
  hook "Set-Content on tool settings"            repo block "$(sh_ PowerShell 'Set-Content .claude/settings.json x')"
  hook "copy onto a protected path"              repo block "$(sh_ Bash 'cp /tmp/p.md .ai/hooks/policy.md')"
  hook "copy from a protected path"              kb   allow "$(sh_ Bash 'cp _kb/templates/requirement-template.md Billing/PRD/002-x/README.md')"
  hook "file a requirement (mv into NNN-slug)"   kb   allow "$(sh_ Bash 'mkdir -p Billing/PRD/002-x && mv Billing/PRD/new.docx Billing/PRD/002-x/')"
  hook "remove PRD .gitkeep"                     kb   allow "$(sh_ Bash 'rm -f Billing/PRD/.gitkeep')"
  hook "delete a requirement document"           kb   block "$(sh_ Bash 'rm Billing/PRD/001-invoice-export/request.txt')"
  hook "overwrite a requirement document"        repo block "$(sh_ Bash 'echo x > ../ProjectKB/Billing/PRD/001-invoice-export/request.txt')"
  hook "PowerShell recursive delete of .."       repo block "$(sh_ PowerShell 'Remove-Item -Recurse -Force ..')"
  hook "PowerShell recursive delete of C:"       repo block "$(sh_ PowerShell 'Remove-Item C:\\ -Recurse')"
  hook "PowerShell recursive delete of a folder" repo allow "$(sh_ PowerShell 'Remove-Item -Recurse -Force .\\build')"
  hook "unparseable input fails closed"          repo block 'not json'
fi

echo "---"
echo "$pass passed, $fail failed"
[ "$fail" -eq 0 ]
