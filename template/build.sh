#!/usr/bin/env bash
set -euo pipefail
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
if [[ -f "$script_dir/../../scripts/build-paper.sh" ]]; then
  exec bash "$script_dir/../../scripts/build-paper.sh" "$script_dir"
fi
exec bash "$script_dir/../scripts/build-paper.sh" "$script_dir"

