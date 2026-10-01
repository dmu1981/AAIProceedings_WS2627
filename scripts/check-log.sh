#!/usr/bin/env bash
set -euo pipefail

log_file="${1:?Usage: check-log.sh LATEX_LOG [BIBER_LOG]}"
biber_log="${2:-}"
[[ -f "$log_file" ]] || { echo "ERROR: Missing LaTeX log: $log_file" >&2; exit 2; }

annotate() { [[ "${GITHUB_ACTIONS:-}" == true ]] && echo "::error title=$1::$2" || true; }

# latexmk has already completed all passes. Unresolved links/citations are now errors.
undefined='LaTeX Warning: (Reference|Citation) .* undefined|LaTeX Warning: There were undefined references|Package biblatex Warning: (Citation .* undefined|Please \(re\)run Biber)'
if grep -Eiq "$undefined" "$log_file"; then
  echo 'ERROR: Unresolved reference or citation in LaTeX log:' >&2
  grep -Ei "$undefined" "$log_file" >&2
  echo 'Hint: every \ref/\autocite needs a matching \label or an entry in your references.bib (check spelling).' >&2
  annotate 'Unresolved reference' 'A \ref or \autocite points to a label/citation key that does not exist.'
  exit 1
fi
multiple='LaTeX Warning: Label `.*'"'"' multiply defined'
if grep -Eiq "$multiple" "$log_file"; then
  echo 'ERROR: A label is defined more than once:' >&2
  grep -Ei "$multiple" "$log_file" >&2
  echo 'Hint: labels must be unique. Use a team prefix such as fig:team-name-architecture.' >&2
  annotate 'Duplicate label' 'A \label is defined more than once; use unique team-prefixed labels.'
  exit 1
fi
if [[ -n "$biber_log" && -f "$biber_log" ]] && grep -Eiq 'WARN - I didn.t find a database entry for|ERROR -' "$biber_log"; then
  echo 'ERROR: Biber reports a missing bibliography entry or another error:' >&2
  grep -Ei 'WARN - I didn.t find a database entry for|ERROR -' "$biber_log" >&2
  echo 'Hint: add the cited key to your references.bib or correct the key in \autocite{...}.' >&2
  annotate 'Bibliography' 'A cited key is missing in references.bib or biber reported an error.'
  exit 1
fi
