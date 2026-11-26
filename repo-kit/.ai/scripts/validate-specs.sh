#!/usr/bin/env bash
# Lints this repo's layer of the knowledge base (PRD folders, plans, this layer's specs, MODULE-MAP.md), where its specs live.
# The checks themselves are in $KB/_kb/scripts/validate-kb.sh, shared by every layer. Exits 1 on any error.
# Usage: bash .ai/scripts/validate-specs.sh
# KB location and layer: .ai/kb.conf (KB=..., LAYER=...); the environment variable SDD_KB overrides KB.
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
CONF="$ROOT/.ai/kb.conf"
[ -f "$CONF" ] || { echo "ERROR  $CONF missing (needs KB=... and LAYER=...)"; exit 1; }

KB=""
LAYER=""
while IFS='=' read -r key value; do
  key="${key//[[:space:]]/}"
  value="${value%%#*}"
  value="$(printf '%s' "$value" | tr -d '\r' | sed -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//' -e 's/^"\(.*\)"$/\1/')"
  case "$key" in
    KB) KB="$value" ;;
    LAYER) LAYER="$value" ;;
  esac
done < "$CONF"

[ -n "$LAYER" ] || { echo "ERROR  LAYER not set in $CONF"; exit 1; }
KB="${SDD_KB:-$KB}"
[ -n "$KB" ] || { echo "ERROR  KB not set in $CONF (or SDD_KB)"; exit 1; }
case "$KB" in /*|[A-Za-z]:*) ;; *) KB="$ROOT/$KB" ;; esac

VALIDATOR="$KB/_kb/scripts/validate-kb.sh"
[ -f "$VALIDATOR" ] || { echo "ERROR  knowledge base not found at '$KB' (no _kb/scripts/validate-kb.sh). Put it where .ai/kb.conf says or set SDD_KB."; exit 1; }
exec bash "$VALIDATOR" --layer "$LAYER" --repo-root "$ROOT"
