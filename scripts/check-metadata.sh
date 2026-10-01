#!/usr/bin/env bash
# Checks a paper's metadata.tex for left-over template placeholders and for the
# author information required by the README (biography length, portrait files).
# Usage: check-metadata.sh PAPER_DIRECTORY
set -uo pipefail

paper_dir="$(cd -- "${1:?Usage: check-metadata.sh PAPER_DIRECTORY}" && pwd)"
meta="$paper_dir/metadata.tex"
name="$(basename "$paper_dir")"
rel="papers/$name/metadata.tex"
errors=0

fail() { # message
  errors=$((errors + 1))
  echo "ERROR in $rel: $1" >&2
  [[ "${GITHUB_ACTIONS:-}" == true ]] && echo "::error file=$rel,title=Metadata::$1"
  return 0
}

[[ -f "$meta" ]] || { echo "ERROR: $rel is missing. Copy it from template/." >&2; exit 1; }

# The template and the fictional example intentionally contain placeholders.
check_placeholders=true
case "$name" in template|example-paper) check_placeholders=false ;; esac

if [[ "$check_placeholders" == true ]]; then
  # Look at the active code only; the template keeps example URLs in comments.
  stripped="$(sed -E 's/\r$//; s/(^|[^\\])%.*$/\1/' "$meta")"
  grep -q 'Your paper title' <<<"$stripped" && fail 'The paper title is still the template placeholder. Set \PaperTitle{...}.'
  grep -q 'your-account\|your-project' <<<"$stripped" && fail 'A GitHub URL still contains "your-account"/"your-project". Set \ProjectRepository{https://github.com/<owner>/<repository>} and remove placeholder profile links.'
  grep -q 'State the concrete problem, your approach' <<<"$stripped" && fail 'The abstract is still the template placeholder. Write your own abstract in \PaperAbstract{...}.'
  grep -q 'First Author' <<<"$stripped" && fail 'The author is still "First Author". Replace the \AddAuthor block with real names.'
  grep -q 'Replace this sample text' <<<"$stripped" && fail 'A biography is still the template sample text.'
fi

# Collect the 7 arguments of every \AddAuthor block (one argument per line).
while IFS=$'\t' read -r author words photo; do
  [[ -n "$author" ]] || continue
  if (( words < 50 || words > 80 )); then
    if [[ "$check_placeholders" == true ]]; then
      fail "The biography of \"$author\" has $words words; it must have 50-80 words (third person)."
    fi
  fi
  if [[ -n "$photo" ]]; then
    if [[ ! -f "$paper_dir/$photo" ]]; then
      fail "Portrait file \"$photo\" of \"$author\" not found. Put it into your paper folder (e.g. authors/first-last.jpg); file names are case-sensitive."
    elif (( $(wc -c < "$paper_dir/$photo") > 512000 )); then
      fail "Portrait \"$photo\" is larger than 500 KB. Scale it down (a square ~400x400 px JPG is enough)."
    fi
  fi
done < <(
  awk '
    { sub(/\r$/, "") }
    /^[ \t]*\\AddAuthor[ \t]*(%.*)?$/ { inblock = 1; n = 0; next }
    inblock && /^[ \t]*\{/ {
      line = $0
      gsub(/(^|[^\\])%.*$/, "", line)             # strip trailing comment
      sub(/^[ \t]*\{/, "", line); sub(/\}[ \t]*$/, "", line)
      n++; arg[n] = line
      if (n == 7) {
        bio = arg[3]; gsub(/\\./, "", bio)
        words = split(bio, w, /[ \t]+/)
        photo = arg[4]; gsub(/^[ \t]+|[ \t]+$/, "", photo)
        printf "%s\t%d\t%s\n", arg[1], words, photo
        inblock = 0
      }
      next
    }
    inblock && !/^[ \t]*(%.*)?$/ { inblock = 0 }
  ' "$meta"
)

authors="$(grep -c '^[[:space:]]*\\AddAuthor' "$meta" || true)"
(( authors >= 1 )) || fail 'No \AddAuthor block found. Add one block per author.'

if (( errors > 0 )); then
  echo "Metadata check failed ($errors problem(s)). Edit $rel and run the build again." >&2
  exit 1
fi
echo "Metadata check passed ($name)."
