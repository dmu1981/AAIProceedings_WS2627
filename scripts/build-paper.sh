#!/usr/bin/env bash
set -euo pipefail

script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$(cd -- "$script_dir/.." && pwd)"
paper_dir="$(cd -- "${1:?Usage: build-paper.sh PAPER_DIRECTORY}" && pwd)"
# shellcheck source=../config/limits.sh
source "$repo_dir/config/limits.sh"
for command_name in latexmk biber pdfinfo; do
  command -v "$command_name" >/dev/null 2>&1 || { echo "ERROR: $command_name is required." >&2; exit 127; }
done
[[ -f "$paper_dir/paper.tex" ]] || { echo "ERROR: No paper.tex in $paper_dir" >&2; exit 2; }
cd "$paper_dir"
bash "$script_dir/check-metadata.sh" "$paper_dir"
mkdir -p .build
rm -f paper.pdf
if ! latexmk -pdf -interaction=nonstopmode -halt-on-error -file-line-error -outdir=.build paper.tex; then
  bash "$script_dir/report-errors.sh" .build/paper.log .build/paper.blg
  exit 1
fi
bash "$script_dir/check-log.sh" .build/paper.log .build/paper.blg
pages="$(pdfinfo .build/paper.pdf | awk '/^Pages:/ { print $2 }')"
[[ "$pages" =~ ^[0-9]+$ ]] || { echo 'ERROR: Could not determine PDF page count.' >&2; exit 2; }
if (( pages > MAX_PAGES )); then
  printf 'ERROR: Paper contains %s pages.\nMaximum allowed number of pages is %s (including references). Shorten text, figures or references.\n' "$pages" "$MAX_PAGES" >&2
  [[ "${GITHUB_ACTIONS:-}" == true ]] && echo "::error title=Page limit::Paper has $pages pages; the maximum is $MAX_PAGES including references."
  exit 1
fi
cp .build/paper.pdf paper.pdf
printf 'Paper validation successful (%s/%s pages). PDF: %s\n' "$pages" "$MAX_PAGES" "$paper_dir/paper.pdf"

