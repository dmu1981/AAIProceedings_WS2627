#!/usr/bin/env bash
set -euo pipefail

log_file="${1:?Usage: check-log.sh LATEX_LOG [BIBER_LOG]}"
biber_log="${2:-}"
[[ -f "$log_file" ]] || { echo "ERROR: Missing LaTeX log: $log_file" >&2; exit 2; }

# latexmk has already completed all passes. Unresolved links/citations are now errors.
if grep -Eiq 'LaTeX Warning: (Reference|Citation) .* undefined|LaTeX Warning: There were undefined references|Package biblatex Warning: (Citation .* undefined|Please \(re\)run Biber)' "$log_file"; then
  echo 'ERROR: Unresolved reference or citation in LaTeX log:' >&2
  grep -Ei 'LaTeX Warning: (Reference|Citation) .* undefined|LaTeX Warning: There were undefined references|Package biblatex Warning: (Citation .* undefined|Please \(re\)run Biber)' "$log_file" >&2
  exit 1
fi
if [[ -n "$biber_log" && -f "$biber_log" ]] && grep -Eiq 'WARN - I didn.t find a database entry for|ERROR -' "$biber_log"; then
  echo 'ERROR: Biber reports a missing bibliography entry or another error:' >&2
  grep -Ei 'WARN - I didn.t find a database entry for|ERROR -' "$biber_log" >&2
  exit 1
fi

