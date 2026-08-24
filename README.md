# BLIST Security Baseline

> **One-command security hardening for every BLIST repository**

This repository contains the standardized security configuration applied across all BLIST ecosystem projects.

---

## 📦 What's Included

| File | Purpose |
|------|---------|
| `.github/dependabot.yml` | Weekly automated dependency updates (npm, GitHub Actions, Docker) |
| `.github/workflows/scorecard.yml` | OpenSSF Scorecard — weekly security posture analysis |
| `.github/workflows/pin-actions.yml` | Pin all GitHub Actions to immutable SHAs (supply chain protection) |
| `.github/workflows/slsa.yml` | SLSA Level 3 provenance generation for releases |
| `SECURITY.md` | Responsible disclosure policy, PGP key, response SLAs |
| `CODEOWNERS` | Mandatory review rules for security-critical files |
| `blist-init-repo.sh` | One-shot installer script |

---

## 🚀 Quick Start

### Option 1: One-liner (recommended)
```bash
curl -fsSL https://raw.githubusercontent.com/blistartunivers-afk/blist-security-baseline/main/blist-init-repo.sh | bash
```

### Option 2: Clone and run
```bash
git clone https://github.com/blistartunivers-afk/blist-security-baseline.git
cd blist-security-baseline
./blist-init-repo.sh /path/to/your/repo
```

### Option 3: Manual copy
Copy the files you need from this repo to your target repository.

---

## 🔧 What the Installer Does

1. **Creates** `.github/workflows/` and `.github/dependabot/` directories
2. **Downloads** all baseline configs from this repo
3. **Updates** `.gitignore` with secret patterns
4. **Configures** branch protection (requires `gh` CLI with admin perms)
5. **Commits** everything with a descriptive message
6. **Prints** next steps

---

## 📋 Post-Install Checklist

After running the installer and pushing:

- [ ] **Enable branch protection** in GitHub UI (Settings → Branches → Branch protection rules)
- [ ] **Add PGP public key** to `SECURITY.md`
- [ ] **Configure SLSA secrets**: `REGISTRY_USERNAME`, `REGISTRY_PASSWORD`
- [ ] **Review first Dependabot PRs** — merge after CI passes
- [ ] **Monitor Scorecard results** — address findings < 7 days
- [ ] **Verify SLSA provenance** on first release

---

## 🔐 Security Features Enabled

| Feature | Standard | Frequency |
|---------|----------|-----------|
| Dependency Updates | Dependabot | Weekly (Mon 03:00) |
| Security Scoring | OpenSSF Scorecard | Weekly (Mon 04:00) |
| Action Pinning | pin-github-action | Weekly (Mon 05:00) |
| Supply Chain | SLSA v1.9 / Provenance | On Release |
| Disclosure Policy | SECURITY.md | Always |
| Code Review | CODEOWNERS | Every PR |

---

## 🛡️ Threat Model Coverage

| Threat | Mitigation |
|--------|------------|
| Dependency confusion / malicious packages | Dependabot + pinned versions + npm audit |
| Compromised GitHub Action (tag mutation) | Pin Actions to SHA |
| Supply chain injection (build tampering) | SLSA provenance + verification |
| Unknown security posture | OpenSSF Scorecard |
| Secret leakage | .gitignore patterns + secret scanning |
| Unreviewed security changes | CODEOWNERS + branch protection |
| Delayed vulnerability response | SECURITY.md SLAs |

---

## 📁 Applying to Existing Repos

The installer is idempotent — safe to run multiple times. It will:
- Overwrite workflow files with latest baseline
- Preserve your custom workflows (non-baseline files untouched)
- Only commit actual changes

---

## 🔄 Updating the Baseline

When this repo is updated, re-run the installer in each target repo:

```bash
./blist-init-repo.sh /path/to/repo
# or
curl -fsSL https://raw.githubusercontent.com/blistartunivers-afk/blist-security-baseline/main/blist-init-repo.sh | bash
```

---

## 📚 References

- [OpenSSF Scorecard](https://github.com/ossf/scorecard)
- [SLSA Framework](https://slsa.dev/)
- [GitHub Dependabot](https://docs.github.com/en/code-security/dependabot)
- [Pin GitHub Action](https://github.com/suzuki-shunsuke/pin-github-action)
- [GitHub Security Advisories](https://docs.github.com/en/code-security/security-advisories)

---

## 📄 License

MIT — Use freely across the BLIST ecosystem.

---

> **Maintained by**: `@estiven` — BLIST Ecosystem
> **Repository**: https://github.com/blistartunivers-afk/blist-security-baseline
