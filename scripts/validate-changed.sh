#!/usr/bin/env bash
set -euo pipefail

base="${1:?Usage: validate-changed.sh BASE_COMMIT HEAD_COMMIT}"
head="${2:?Usage: validate-changed.sh BASE_COMMIT HEAD_COMMIT}"
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$(cd -- "$script_dir/.." && pwd)"
cd "$repo_dir"

declare -A changed=()
shared_touched=()
all_papers=false
build_proceedings=false
while IFS= read -r -d '' file; do
  case "$file" in
    papers/*/metadata.tex|papers/*/authors/*)
      paper_name="${file#papers/}"; changed["${paper_name%%/*}"]=1; build_proceedings=true ;;
    papers/*/*) paper_name="${file#papers/}"; changed["${paper_name%%/*}"]=1 ;;
    proceedings/*|config/*) all_papers=true; build_proceedings=true; shared_touched+=("$file") ;;
    scripts/*|template/*|.github/*) all_papers=true; shared_touched+=("$file") ;;
  esac
done < <(git diff --name-only -z "$base" "$head")

if (( ${#shared_touched[@]} > 0 )); then
  echo "WARNING: This change modifies shared files (${shared_touched[*]}). Students should only change their own papers/<team-name>/ folder." >&2
  [[ "${GITHUB_ACTIONS:-}" == true ]] && echo "::warning title=Shared files changed::Only the editorial team should change proceedings/, config/, scripts/, template/ or .github/. Students: please revert these changes."
fi

if [[ "$all_papers" == true ]]; then
  for dir in papers/*; do
    [[ -d "$dir" ]] || continue
    changed["${dir#papers/}"]=1
  done
fi

if (( ${#changed[@]} == 0 )) && [[ "$build_proceedings" == false ]]; then
  echo 'Paper validation successful (no affected papers).'
  exit 0
fi
for paper_name in "${!changed[@]}"; do
  [[ -d "papers/$paper_name" ]] || continue # A deleted paper has nothing to build.
  echo "Validating papers/$paper_name"
  bash "papers/$paper_name/build.sh"
done
if [[ "$build_proceedings" == true ]]; then
  echo 'Validating proceedings after shared-file changes'
  bash proceedings/build.sh
fi
echo 'Paper validation successful.'

