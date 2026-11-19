#!/usr/bin/env bash
# Lints the knowledge base: requirement folders (SRS), plans (Planning), the specs of every layer in _kb/kb.conf
# (metadata, mandatory sections, index registration and status drift, links, Verification Matrix) and MODULE-MAP.md
# coverage. Exits 1 on any error.
# Usage: bash _kb/scripts/validate-kb.sh [--layer <layer>|all] [--repo-root DIR]
#   --repo-root  the repo of the selected layer (only with a single --layer); default: kb.conf, or env SDD_REPO_<LAYER>.
# Each product repo calls it through its own .ai/scripts/validate-specs.sh, which passes --layer and its repo root.
# Portable to bash 3.2 (macOS): no associative arrays.
set -euo pipefail

KB="$(cd "$(dirname "$0")/../.." && pwd)"
CONF="$KB/_kb/kb.conf"
LAYER=all
REPO_ROOT=""
while [ $# -gt 0 ]; do
  case "$1" in
    --layer) LAYER="$2"; shift 2 ;;
    --repo-root) REPO_ROOT="$2"; shift 2 ;;
    *) echo "unknown argument: $1"; exit 2 ;;
  esac
done

MAP="$KB/MODULE-MAP.md"
CROSS=_cross-cutting
errors=0
warnings=0

err()  { echo "ERROR  $1: $2"; errors=$((errors + 1)); }
warn() { echo "WARN   $1: $2"; warnings=$((warnings + 1)); }
trim() { local s="${1//$'\r'/}"; s="${s#"${s%%[![:space:]]*}"}"; printf '%s' "${s%"${s##*[![:space:]]}"}"; }
upper() { printf '%s' "$1" | tr '[:lower:]-' '[:upper:]_'; }

# --- Layers from _kb/kb.conf ----------------------------------------------------------------------------
[ -f "$CONF" ] || { echo "ERROR  _kb/kb.conf missing"; exit 1; }
L_NAME=(); L_FOLDER=(); L_PREFIX=(); L_INDEX=(); L_REPO=(); L_CONSUMES=()
while read -r name folder prefix index repo consumes _; do
  name="$(trim "$name")"
  case "$name" in ''|\#*) continue ;; esac
  [ -n "${consumes:-}" ] || { echo "ERROR  _kb/kb.conf: row '$name' needs 6 columns (layer folder prefix index repo consumes)"; exit 1; }
  L_NAME+=("$name"); L_FOLDER+=("$folder"); L_PREFIX+=("$prefix"); L_INDEX+=("$index"); L_REPO+=("$repo"); L_CONSUMES+=("$(trim "$consumes")")
done < "$CONF"
[ ${#L_NAME[@]} -gt 0 ] || { echo "ERROR  _kb/kb.conf defines no layer"; exit 1; }

layer_pos() { local i; for i in "${!L_NAME[@]}"; do [ "${L_NAME[$i]}" = "$1" ] && { echo "$i"; return 0; }; done; return 1; }

if [ "$LAYER" != all ]; then
  layer_pos "$LAYER" >/dev/null || { echo "ERROR  --layer '$LAYER' is not a layer in _kb/kb.conf (${L_NAME[*]})"; exit 2; }
elif [ -n "$REPO_ROOT" ]; then
  echo "ERROR  --repo-root needs a single --layer"; exit 2
fi

PREFIXES="$(IFS='|'; echo "${L_PREFIX[*]}")"
ID_RE="\\b(REQ|$PREFIXES)-([A-Za-z][A-Za-z0-9]*-)?[0-9]{3}\\b"

for i in "${!L_NAME[@]}"; do
  [ "${L_PREFIX[$i]}" != REQ ] || { echo "ERROR  _kb/kb.conf: prefix REQ is reserved for requirements"; exit 1; }
  [ -f "$KB/${L_INDEX[$i]}" ] || { echo "ERROR  ${L_INDEX[$i]} missing (create it from _kb/templates/spec-index-template.md)"; exit 1; }
  if [ "${L_CONSUMES[$i]}" != - ]; then
    layer_pos "${L_CONSUMES[$i]}" >/dev/null || { echo "ERROR  _kb/kb.conf: '${L_NAME[$i]}' consumes unknown layer '${L_CONSUMES[$i]}'"; exit 1; }
  fi
done
[ -f "$MAP" ] || { echo "ERROR  MODULE-MAP.md missing"; exit 1; }

# Value of a "| Field | Value |" metadata row.
field() {
  awk -F'|' -v k="$2" '{ gsub(/^[ \t]+|[ \t\r]+$/, "", $2) } $2 == k { v = $3; gsub(/^[ \t]+|[ \t\r]+$/, "", v); print v; exit }' "$1"
}

# <prefix>-<Module>-NNN, or <prefix>-NNN for _cross-cutting.
expected_id() { if [ "$2" = "$CROSS" ]; then echo "$1-$3"; else echo "$1-$2-$3"; fi; }

# The ID appears in MODULE-MAP.md as a whole token.
in_map() { grep -qE "(^|[^A-Za-z0-9-])$1([^A-Za-z0-9-]|$)" "$MAP"; }

# The ID has a row in an index file.
in_index() { grep -qE "^\|[[:space:]]*$2[[:space:]]*\|" "$1"; }

SECTIONS=(
  "## Metadata"
  "## 1. Problem Statement & Motivation"
  "## 2. Architectural Boundaries & Data Flow"
  "## 3. Data Schemas & API Contracts"
  "## 4. Error Modes, Invariants & Edge Cases"
  "## 5. Verification Matrix"
)

shopt -s nullglob

# --- Requirements: <Module>/SRS/NNN-slug/README.md = REQ-<Module>-NNN -------------------------------------
REQS=" "
for dir in "$KB"/*/SRS/[0-9][0-9][0-9]-*/; do
  dir="${dir%/}"
  rel="${dir#"$KB"/}"
  module="$(basename "$(dirname "$(dirname "$dir")")")"
  num="$(basename "$dir")"; num="${num%%-*}"
  expected="$(expected_id REQ "$module" "$num")"
  REQS="$REQS$expected "
  if [ ! -f "$dir/README.md" ]; then
    err "$rel" "missing README.md (start from _kb/templates/requirement-template.md)"
  else
    id="$(field "$dir/README.md" ID)"
    [ "$id" = "$expected" ] || err "$rel" "README ID '$id' does not match folder (expected $expected)"
  fi
  [ -n "$(find "$dir" -mindepth 1 -maxdepth 1 ! -name README.md | head -1)" ] || warn "$rel" "no requirement documents next to README.md"
  in_map "$expected" || err "$rel" "$expected missing from MODULE-MAP.md"
  echo "INFO   $rel: $expected"
done

# Requirement documents dropped straight into SRS/ are new requirements waiting for intake.
for f in "$KB"/*/SRS/*; do
  name="$(basename "$f")"
  [ "$name" = .gitkeep ] && continue
  [[ -d "$f" && "$name" =~ ^[0-9]{3}- ]] && continue
  warn "${f#"$KB"/}" "unfiled requirement: run plan-requirement (in the KB) or intake-requirement (in a repo) to give it a REQ folder and a plan"
done

# --- Plans: <Module>/Planning/NNN-slug/plan.md, same folder name as the requirement it plans --------------
for dir in "$KB"/*/Planning/[0-9][0-9][0-9]-*/; do
  dir="${dir%/}"
  rel="${dir#"$KB"/}"
  module="$(basename "$(dirname "$(dirname "$dir")")")"
  num="$(basename "$dir")"; num="${num%%-*}"
  expected="$(expected_id REQ "$module" "$num")"
  [ -d "$KB/$module/SRS/$(basename "$dir")" ] || err "$rel" "no requirement folder $module/SRS/$(basename "$dir")/ (a plan has the same folder name as its requirement)"
  plan="$dir/plan.md"
  [ -f "$plan" ] || { err "$rel" "missing plan.md (start from .ai/templates/plan-template.md)"; continue; }
  req="$(field "$plan" Requirement)"
  grep -qE "(^|[^A-Za-z0-9-])$expected([^A-Za-z0-9-]|$)" <<< "$req" || err "$rel" "Requirement '$req' does not name $expected"
  status="$(field "$plan" Status)"
  case "$status" in
    Draft|Approved) ;;
    *) err "$rel" "invalid Status '$status' (Draft|Approved)" ;;
  esac
  if [ "$status" = Approved ] && grep -nE '\b(TBD|TODO)\b' "$plan" >/dev/null; then
    err "$rel" "Approved plan still contains TBD/TODO (lines: $(grep -nE '\b(TBD|TODO)\b' "$plan" | cut -d: -f1 | paste -sd, -))"
  fi
  echo "INFO   $rel: plan for $expected $status"
done

# --- Specs: <Module>/Implementation/<folder>/NNN-slug/ ------------------------------------------------------
# Index file of the layer that owns an ID prefix.
index_for_prefix() { local i; for i in "${!L_PREFIX[@]}"; do [ "${L_PREFIX[$i]}" = "$1" ] && { echo "$KB/${L_INDEX[$i]}"; return 0; }; done; return 1; }

validate_layer() {
  local i="$1"
  local layer="${L_NAME[$i]}" folder="${L_FOLDER[$i]}" prefix="${L_PREFIX[$i]}" index="$KB/${L_INDEX[$i]}" root
  local env_name; env_name="SDD_REPO_$(upper "$layer")"
  if [ -n "$REPO_ROOT" ]; then root="$REPO_ROOT"
  elif [ -n "${!env_name:-}" ]; then root="${!env_name}"
  else case "${L_REPO[$i]}" in /*|[A-Za-z]:*) root="${L_REPO[$i]}" ;; *) root="$KB/${L_REPO[$i]}" ;; esac
  fi

  local fields=(ID Title Status Version Author Dependencies Requirements "Last Updated")
  local provider_field=""
  if [ "${L_CONSUMES[$i]}" != - ]; then
    provider_field="${L_FOLDER[$(layer_pos "${L_CONSUMES[$i]}")]} Specs"
    fields+=("$provider_field")
  fi

  local dirs=("$KB"/*/Implementation/"$folder"/[0-9][0-9][0-9]-*/)
  if [ ! -d "$root" ]; then
    [ ${#dirs[@]} -eq 0 ] || warn "$layer" "repo root '$root' not found: Verification Matrix test references are not checked"
    root=""
  fi

  local dir
  for dir in ${dirs[@]+"${dirs[@]}"}; do
    dir="${dir%/}"
    local rel="${dir#"$KB"/}" spec="$dir/spec.md"
    [ -f "$spec" ] || { err "$rel" "missing spec.md"; continue; }
    [ -f "$dir/changelog.md" ] || err "$rel" "missing changelog.md"

    local f
    for f in "${fields[@]}"; do
      [ -n "$(field "$spec" "$f")" ] || err "$rel" "metadata field '$f' missing or empty"
    done

    local id status module num expected
    id="$(field "$spec" ID)"
    status="$(field "$spec" Status)"
    module="$(basename "$(dirname "$(dirname "$(dirname "$dir")")")")"
    num="$(basename "$dir")"; num="${num%%-*}"
    expected="$(expected_id "$prefix" "$module" "$num")"
    [ "$id" = "$expected" ] || err "$rel" "ID '$id' does not match folder (expected $expected)"
    case "$status" in
      Draft|Approved|Deprecated) ;;
      *) err "$rel" "invalid Status '$status' (Draft|Approved|Deprecated)" ;;
    esac

    local s
    for s in "${SECTIONS[@]}"; do
      grep -qF -- "$s" "$spec" || err "$rel" "missing section '$s'"
    done

    # Index registration and status drift.
    local idx_status
    idx_status="$(awk -F'|' -v id="$id" '{ for (i = 2; i <= NF; i++) gsub(/^[ \t]+|[ \t\r]+$/, "", $i) } $2 == id { print $4; exit }' "$index")"
    if [ -z "$idx_status" ]; then
      err "$rel" "$id not registered in $(basename "$index")"
    elif [ "$idx_status" != "$status" ]; then
      err "$rel" "status drift: spec says '$status', $(basename "$index") says '$idx_status'"
    fi
    in_map "$id" || err "$rel" "$id missing from MODULE-MAP.md"

    # Link rows: every referenced ID exists, every markdown link resolves.
    local val ref link ref_index
    for f in Dependencies Dependents Requirements ${provider_field:+"$provider_field"}; do
      val="$(field "$spec" "$f")"
      [ -n "$val" ] || continue
      for ref in $(grep -oE "$ID_RE" <<< "$val" || true); do
        case "$ref" in
          REQ-*) [[ "$REQS" == *" $ref "* ]] || err "$rel" "$f references $ref, which has no SRS folder" ;;
          *)
            ref_index="$(index_for_prefix "${ref%%-*}")"
            in_index "$ref_index" "$ref" || err "$rel" "$f references $ref, which is not registered in $(basename "$ref_index")" ;;
        esac
      done
      for link in $(grep -oE '\]\([^)]+\)' <<< "$val" | sed -E 's/^\]\((.*)\)$/\1/' || true); do
        [ -e "$dir/$link" ] || err "$rel" "$f link '$link' does not resolve"
      done
    done

    # Verification Matrix rows: | AC-NN | criterion | covers | test ref | status |
    local rows
    rows="$(awk -F'|' '$2 ~ /^[ \t]*AC-[0-9]+[ \t]*$/' "$spec")"
    if [ -z "$rows" ]; then
      if [ "$status" = Approved ]; then err "$rel" "no AC rows in Verification Matrix"; else warn "$rel" "no AC rows yet"; fi
      continue
    fi

    local total=0 verified=0 ac st
    while IFS='|' read -r _ ac _ _ ref st _; do
      ac="$(trim "$ac")"; ref="$(trim "${ref//\`/}")"; st="$(trim "$st")"
      total=$((total + 1))
      case "$st" in
        Verified) verified=$((verified + 1)) ;;
        Pending|Failing) ;;
        *) err "$rel" "$ac has invalid status '$st' (Pending|Verified|Failing)" ;;
      esac
      if [ -z "$ref" ] || [ "$ref" = TBD ] || [ "$ref" = "—" ] || [ "$ref" = "-" ]; then
        if [ "$status" = Approved ] || [ "$st" = Verified ]; then err "$rel" "$ac has no test reference"; fi
      elif [ -n "$root" ] && [ ! -e "$root/${ref%%::*}" ]; then
        if [ "$st" = Verified ]; then err "$rel" "$ac marked Verified but '${ref%%::*}' does not exist"
        else warn "$rel" "$ac test '${ref%%::*}' does not exist yet"; fi
      fi
    done <<< "$rows"

    if [ "$status" = Approved ] && grep -nE '\b(TBD|TODO)\b' "$spec" >/dev/null; then
      err "$rel" "Approved spec still contains TBD/TODO (lines: $(grep -nE '\b(TBD|TODO)\b' "$spec" | cut -d: -f1 | paste -sd, -))"
    fi

    echo "INFO   $rel: $id $status coverage $verified/$total"
  done

  # Index rows whose folder is gone (column 10 = Folder).
  local fdir
  for fdir in $(awk -F'|' -v p="$prefix" '$2 ~ "^[ \t]*" p "-[A-Za-z0-9]" { f = $10; gsub(/[ \t`\r]/, "", f); print f }' "$index"); do
    [ -d "$KB/$fdir" ] || err "$(basename "$index")" "folder '$fdir' does not exist"
  done
}

for i in "${!L_NAME[@]}"; do
  [ "$LAYER" = all ] || [ "$LAYER" = "${L_NAME[$i]}" ] || continue
  validate_layer "$i"
done

# --- MODULE-MAP.md: every link resolves -----------------------------------------------------------------
for link in $(grep -oE '\]\([^)]+\)' "$MAP" | sed -E 's/^\]\((.*)\)$/\1/' || true); do
  case "$link" in http*|\#*) continue ;; esac
  [ -e "$KB/${link%%#*}" ] || err "MODULE-MAP.md" "link '$link' does not resolve"
done

echo "---"
echo "$errors error(s), $warnings warning(s)"
[ "$errors" -eq 0 ]
