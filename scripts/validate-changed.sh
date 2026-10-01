#!/usr/bin/env bash
set -euo pipefail

base="${1:?Usage: validate-changed.sh BASE_COMMIT HEAD_COMMIT}"
head="${2:?Usage: validate-changed.sh BASE_COMMIT HEAD_COMMIT}"
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
repo_dir="$(cd -- "$script_dir/.." && pwd)"
cd "$repo_dir"

declare -A changed=()
all_papers=false
build_proceedings=false
while IFS= read -r -d '' file; do
  case "$file" in
    papers/*/*) paper_name="${file#papers/}"; changed["${paper_name%%/*}"]=1 ;;
    proceedings/*|config/*) all_papers=true; build_proceedings=true ;;
    scripts/*|template/*) all_papers=true ;;
  esac
done < <(git diff --name-only -z "$base" "$head")

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

