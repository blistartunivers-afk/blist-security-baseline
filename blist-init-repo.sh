#!/usr/bin/env bash
# Prepare security configuration without committing unrelated user changes.
set -euo pipefail
TARGET_DIR="${1:-.}"
BASELINE_REPO="blistartunivers-afk/blist-security-baseline"
BASELINE_BRANCH="${BASELINE_BRANCH:-master}"
cd "$TARGET_DIR"
git rev-parse --show-toplevel >/dev/null
if [[ "$(git rev-parse --show-prefix)" != "" ]]; then
  echo "Run against the repository root." >&2; exit 1
fi
staging=$(mktemp -d)
trap 'rm -rf "$staging"' EXIT
files=(
  .github/dependabot.yml
  .github/workflows/scorecard.yml
  .github/workflows/bandit.yml
  .github/workflows/codeql.yml
  .github/workflows/pin-actions.yml
  .github/workflows/slsa.yml
  .github/workflows/secret-scanning.yml
  scripts/check_action_pins.py
  SECURITY.md
  CODEOWNERS
)
# Fetch everything first. A failed download leaves the target unchanged.
for file in "${files[@]}"; do
  mkdir -p "$staging/$(dirname "$file")"
  curl --fail --silent --show-error --location --retry 2 \
    "https://raw.githubusercontent.com/$BASELINE_REPO/$BASELINE_BRANCH/$file" \
    -o "$staging/$file"
done
backup_dir="$(git rev-parse --git-path blist-baseline-backups)/$(date +%Y%m%d-%H%M%S)-$$"
for file in "${files[@]}"; do
  if [[ -f "$file" ]] && cmp -s "$file" "$staging/$file"; then continue; fi
  if [[ -e "$file" ]]; then
    mkdir -p "$backup_dir/$(dirname "$file")"
    cp -p "$file" "$backup_dir/$file"
  fi
  mkdir -p "$(dirname "$file")"
  cp "$staging/$file" "$file"
done
if [[ -f .gitignore ]]; then
  mkdir -p "$backup_dir"; cp -p .gitignore "$backup_dir/.gitignore"
fi
for entry in '*.pem' '*.key' '*.gpg' '.env*' '*.secret' 'secrets/'; do
  if ! grep -qxF -- "$entry" .gitignore 2>/dev/null; then
    printf '\n%s\n' "$entry" >> .gitignore
  fi
done
printf 'Baseline prepared. Backups: %s\n' "$backup_dir"
printf 'Review git diff, run checks, then stage and commit the intended files.\n'
printf 'Branch protection and repository settings were not changed.\n'
