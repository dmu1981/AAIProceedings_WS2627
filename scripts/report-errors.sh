#!/usr/bin/env bash
# Prints a short, human-readable summary of the first LaTeX/Biber errors after a
# failed build, with a hint on how to fix common problems. On GitHub Actions the
# errors are also attached to the file/line in the pull request ("annotations").
# Run it from the directory that was used for the build.
# Usage: report-errors.sh LATEX_LOG [BIBER_LOG]
set -uo pipefail

log_file="${1:?Usage: report-errors.sh LATEX_LOG [BIBER_LOG]}"
biber_log="${2:-}"
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$(cd -- "$script_dir/.." && pwd)"

hint_for() {
  case "$1" in
    *"No project repository URL"*|*"must start with https://github.com/"*)
      echo 'Set \ProjectRepository{https://github.com/<owner>/<repository>} in your metadata.tex.' ;;
    *"Missing paper title"*) echo 'Set \PaperTitle{...} in your metadata.tex.' ;;
    *"Missing paper authors"*) echo 'Add at least one \AddAuthor{...} block to your metadata.tex.' ;;
    *"Undefined control sequence"*)
      echo 'A LaTeX command is misspelled or not available. The command is shown in the "l.<line>" excerpt of the log.' ;;
    *"not found"*)
      echo 'A file is missing. Check the path and the exact spelling: file names are case-sensitive on GitHub (Linux). Figures belong into figures/ and are loaded with \subfix{figures/name.pdf}.' ;;
    *"Missing \$ inserted"*)
      echo 'Math characters (_ ^) used in normal text. Write \_ for an underscore or put formulas between $...$.' ;;
    *"Misplaced alignment tab"*) echo 'Write \& instead of a bare & in normal text.' ;;
    *"Missing } inserted"*|*"Extra }"*|*"Runaway argument"*|*"Paragraph ended before"*|*"Too many }"*)
      echo 'Unbalanced curly braces { }. Check the lines directly above the reported line.' ;;
    *"Unicode character"*)
      echo 'A character is not supported by the font. Replace it by a standard character or a LaTeX command (e.g. \"u for ü).' ;;
    *"Environment"*"undefined"*) echo 'An \begin{...} refers to an unknown environment; check the spelling or the missing package.' ;;
    *"Emergency stop"*|*"Fatal error"*) echo 'LaTeX could not continue; fix the first error listed above.' ;;
    *) echo '' ;;
  esac
}

annotate() { # file line message
  [[ "${GITHUB_ACTIONS:-}" == true ]] || return 0
  local file="$1" line="$2" msg="$3" rel
  rel="$(realpath -m --relative-to="$repo_dir" "$file" 2>/dev/null || true)"
  if [[ -n "$rel" && "$rel" != ..* ]]; then
    echo "::error file=$rel,line=$line,title=LaTeX error::$msg"
  else
    echo "::error title=LaTeX error::$msg"
  fi
}

found=0
if [[ -f "$log_file" ]]; then
  # With -file-line-error every error looks like "./paper.tex:42: message".
  while IFS=$'\t' read -r file line msg; do
    found=$((found + 1))
    hint="$(hint_for "$msg")"
    {
      echo
      echo "================ LaTeX error #$found ================"
      echo "Where  : $file, line $line"
      echo "Problem: $msg"
      [[ -n "$hint" ]] && echo "Hint   : $hint"
    } >&2
    annotate "$file" "$line" "$msg${hint:+ -- $hint}"
  done < <(sed -n 's/\r$//; s/^\(\.\{0,2\}\/\{0,1\}[^ :]*\.\(tex\|cls\|sty\|bib\)\):\([0-9]\+\): \(.*\)$/\1\t\3\t\4/p' "$log_file" | grep -v "==> Fatal" | head -n 3)
fi

if [[ -n "$biber_log" && -f "$biber_log" ]] && grep -q 'ERROR -' "$biber_log"; then
  found=$((found + 1))
  {
    echo
    echo '================ Bibliography (biber) error ================'
    grep 'ERROR -' "$biber_log" | head -n 3
    echo 'Hint   : Check references.bib for missing braces/commas or a missing file.'
  } >&2
  [[ "${GITHUB_ACTIONS:-}" == true ]] && echo '::error title=Bibliography error::biber reported an error in references.bib'
fi

if (( found == 0 )); then
  {
    echo
    echo "The build failed, but no specific LaTeX error was found. Open $log_file and search for '!' or 'Error'."
  } >&2
fi
{
  echo
  echo "Full log: $log_file"
  echo 'Fix the FIRST error first; later errors are often only consequences of it.'
} >&2
exit 0
