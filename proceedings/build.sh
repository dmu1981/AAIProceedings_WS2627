#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
cd "$script_dir"
for command_name in latexmk biber; do
  command -v "$command_name" >/dev/null 2>&1 || { echo "ERROR: $command_name is required." >&2; exit 127; }
done
mkdir -p .build
rm -f proceedings.pdf
if ! latexmk -pdf -interaction=nonstopmode -halt-on-error -file-line-error -outdir=.build main.tex; then
  "$script_dir/../scripts/report-errors.sh" .build/main.log .build/main.blg
  exit 1
fi
"$script_dir/../scripts/check-log.sh" .build/main.log .build/main.blg
cp .build/main.pdf proceedings.pdf
printf 'Proceedings PDF: %s\n' "$script_dir/proceedings.pdf"

