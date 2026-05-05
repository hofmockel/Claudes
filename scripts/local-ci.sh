#!/usr/bin/env bash
# local-ci.sh — runs the exact CI check sequence locally before pushing
# Exit code 0 = all pass, 1 = one or more failed

set -euo pipefail

RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

FAILED=0

run_check() {
  local name="$1"
  shift
  echo -n "  $name ... "
  if output=$("$@" 2>&1); then
    echo -e "${GREEN}pass${NC}"
  else
    echo -e "${RED}FAIL${NC}"
    echo "$output" | head -20
    FAILED=1
  fi
}

echo "=== Local CI ==="
echo ""

run_check "ruff"      ruff check .
run_check "mypy"      mypy . --ignore-missing-imports
run_check "pytest"    pytest --tb=short -q

if [[ -d ".github/workflows" ]]; then
  if command -v actionlint &>/dev/null; then
    run_check "actionlint" actionlint
  else
    echo "  actionlint ... skipped (not installed)"
  fi
fi

echo ""
if [[ $FAILED -eq 0 ]]; then
  echo -e "${GREEN}All checks passed.${NC}"
  exit 0
else
  echo -e "${RED}One or more checks failed. Do not push until green.${NC}"
  exit 1
fi
