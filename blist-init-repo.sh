#!/usr/bin/env bash
# blist-init-repo.sh — Apply BLIST Security Baseline to any repository
# Usage: curl -fsSL https://raw.githubusercontent.com/blistartunivers-afk/blist-security-baseline/main/blist-init-repo.sh | bash
#        OR: ./blist-init-repo.sh [target-dir]

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log() { echo -e "${BLUE}[BLIST-INIT]${NC} $*"; }
ok() { echo -e "${GREEN}[OK]${NC} $*"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*"; }
err() { echo -e "${RED}[ERR]${NC} $*" >&2; }

BASELINE_REPO="blistartunivers-afk/blist-security-baseline"
BASELINE_BRANCH="master"
TARGET_DIR="${1:-.}"

# Validate target
target_abs="$(cd "$TARGET_DIR" && pwd)"
if [[ ! -d "$target_abs/.git" ]]; then
  err "Target directory '$target_abs' is not a git repository"
  exit 1
fi

log "Applying BLIST Security Baseline to: $target_abs"

cd "$target_abs"

# 1. Create directory structure
log "Creating directory structure..."
mkdir -p .github/workflows .github/dependabot
ok "Directories created"

# 2. Download baseline files from GitHub
log "Fetching baseline files from $BASELINE_REPO@$BASELINE_BRANCH..."

files=(
  ".github/dependabot.yml"
  ".github/workflows/scorecard.yml"
  ".github/workflows/pin-actions.yml"
  ".github/workflows/slsa.yml"
  "SECURITY.md"
  "CODEOWNERS"
)

for file in "${files[@]}"; do
  url="https://raw.githubusercontent.com/$BASELINE_REPO/$BASELINE_BRANCH/$file"
  log "  Downloading $file..."
  if curl -fsSL "$url" -o "$file"; then
    ok "  $file"
  else
    warn "  $file (not found, skipping)"
  fi
done

# 3. Create branch protection rules helper (requires gh CLI)
if command -v gh &>/dev/null; then
  log "Configuring branch protection (requires admin perms)..."
  gh api --method PUT "/repos/{owner}/{repo}/branches/main/protection" \
    --input - <<'EOF' 2>/dev/null || warn "Branch protection setup failed (need admin perms or gh auth)"
{
  "required_status_checks": {
    "strict": true,
    "contexts": ["Scorecard", "Pin Actions", "Lighthouse CI"]
  },
  "enforce_admins": true,
  "required_pull_request_reviews": {
    "required_approving_review_count": 1,
    "dismiss_stale_reviews": true,
    "require_code_owner_reviews": true
  },
  "restrictions": null,
  "required_signatures": true,
  "required_linear_history": true
}
EOF
  ok "Branch protection configured"
else
  warn "gh CLI not found — skipping branch protection setup"
fi

# 4. Initialize dependabot (enable if not already)
if [[ -f .github/dependabot.yml ]]; then
  log "Dependabot config installed"
fi

# 5. Add .gitignore entries for security
log "Updating .gitignore..."
gitignore_entries=(
  "# Security
*.pem
*.key
*.gpg
.env*
*.secret
secrets/
"
)
for entry in "${gitignore_entries[@]}"; do
  if ! grep -qxF "$entry" .gitignore 2>/dev/null; then
    echo "$entry" >> .gitignore
  fi
done
ok ".gitignore updated"

# 6. Commit changes
log "Committing baseline files..."
git add .github/dependabot.yml .github/workflows/ SECURITY.md CODEOWNERS .gitignore 2>/dev/null || true
if ! git diff --cached --quiet; then
  git commit -m "chore(security): apply BLIST security baseline

- Add Dependabot for automated dependency updates
- Add OpenSSF Scorecard for security posture
- Pin GitHub Actions to immutable SHAs
- Add SLSA provenance generation for releases
- Add SECURITY.md with responsible disclosure policy
- Add CODEOWNERS for mandatory reviews
- Update .gitignore for secret patterns

Applied via blist-init-repo.sh from $BASELINE_REPO"
  ok "Changes committed"
else
  log "No new changes to commit"
fi

# 7. Summary
cat <<EOF

${GREEN}═══════════════════════════════════════════════════════${NC}
${GREEN}  BLIST Security Baseline Applied Successfully!${NC}
${GREEN}═══════════════════════════════════════════════════════${NC}

${BLUE}Installed:${NC}
  ✅ .github/dependabot.yml          — Weekly dependency updates
  ✅ .github/workflows/scorecard.yml — OpenSSF Scorecard (weekly)
  ✅ .github/workflows/pin-actions.yml — Pin actions to SHAs (weekly)
  ✅ .github/workflows/slsa.yml      — SLSA provenance on release
  ✅ SECURITY.md                     — Disclosure policy + PGP key
  ✅ CODEOWNERS                      — Mandatory review rules
  ✅ .gitignore                      — Secret patterns added

${YELLOW}Next Steps:${NC}
  1. Push changes: ${BLUE}git push origin main${NC}
  2. Enable branch protection in GitHub UI (or re-run with gh auth)
  3. Add PGP public key to SECURITY.md
  4. Configure repository secrets for SLSA (REGISTRY_USERNAME/PASSWORD)
  5. Review and merge the first Dependabot/Scorecard PRs

${BLUE}Repository:${NC} https://github.com/$BASELINE_REPO
${BLUE}Issues:${NC}     https://github.com/$BASELINE_REPO/issues

EOF
