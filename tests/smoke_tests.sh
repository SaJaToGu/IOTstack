#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

required_paths=(
  "README.md"
  "menu.sh"
  "scripts/start.sh"
  "scripts/stop.sh"
  "scripts/restart.sh"
  ".native/rpieasy.sh"
  ".native/rtl_433.sh"
)

for path in "${required_paths[@]}"; do
  if [[ ! -e "$path" ]]; then
    echo "Missing required path: $path" >&2
    exit 1
  fi
done

while IFS= read -r -d '' script; do
  bash -n "$script"
done < <(find . -type f -name "*.sh" -not -path "./.git/*" -print0)

echo "Smoke tests passed."
