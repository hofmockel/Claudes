#!/usr/bin/env bash
# preflight.sh — run at session start to surface env/toolchain blockers early

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ok()   { echo -e "  ${GREEN}OK${NC}    $1"; }
fail() { echo -e "  ${RED}MISSING${NC} $1"; FAILED=1; }
warn() { echo -e "  ${YELLOW}WARN${NC}  $1"; }

FAILED=0

echo "=== Claude Code Preflight Check ==="
echo ""

# --- Environment Variables ---
echo "Environment Variables:"

check_env() {
  local var="$1"
  local desc="$2"
  if [[ -n "${!var:-}" ]]; then
    ok "$var ($desc)"
  else
    fail "$var ($desc) — not set"
  fi
}

# Load .env if present
if [[ -f ".env" ]]; then
  ok ".env file found and loaded"
  set -a
  # shellcheck disable=SC1091
  source .env 2>/dev/null || warn ".env found but could not be sourced"
  set +a
else
  warn ".env file not found in $(pwd)"
fi

# Add project-specific env vars here:
# check_env "MY_API_KEY" "description"

echo ""

# --- GitHub CLI ---
echo "GitHub CLI:"

if ! command -v gh &>/dev/null; then
  fail "gh CLI not installed"
else
  if gh auth status &>/dev/null 2>&1; then
    ok "gh auth: authenticated"

    # Check for required scopes
    GH_SCOPES=$(gh auth status 2>&1 | grep -i "token scopes" || echo "")
    if echo "$GH_SCOPES" | grep -q "repo"; then
      ok "gh scope: repo"
    else
      fail "gh scope: repo — missing (run: gh auth refresh -s repo)"
    fi
    if echo "$GH_SCOPES" | grep -q "workflow"; then
      ok "gh scope: workflow"
    else
      fail "gh scope: workflow — missing (run: gh auth refresh -s workflow)"
    fi
  else
    fail "gh auth: not authenticated (run: gh auth login)"
  fi
fi

echo ""

# --- Python toolchain ---
echo "Python Toolchain:"

for tool in ruff mypy pytest; do
  if command -v "$tool" &>/dev/null; then
    ok "$tool ($(${tool} --version 2>&1 | head -1))"
  else
    warn "$tool not found in PATH"
  fi
done

echo ""

# --- Summary ---
if [[ $FAILED -eq 0 ]]; then
  echo -e "${GREEN}All checks passed — good to go.${NC}"
  exit 0
else
  echo -e "${RED}One or more checks failed. Fix the issues above before starting your session.${NC}"
  exit 1
fi
