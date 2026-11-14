# BLIST Security Baseline

Reusable GitHub security configuration for BLIST repositories. Review each workflow for the target repository before enabling it; CodeQL and Bandit currently assume Python code.

## Contents

- `.github/dependabot.yml`: proposed dependency and action updates.
- `.github/workflows/`: pinned action check, Bandit, CodeQL, Scorecard, TruffleHog, and source archive provenance.
- `SECURITY.md` and `CODEOWNERS`: disclosure and review guidance. CODEOWNERS requires branch protection to enforce reviews.
- `scripts/check_action_pins.py`: validates immutable external action references.
- `blist-init-repo.sh`: downloads baseline files into a target Git repository, backing up overwritten files under its Git directory.

## Apply to a repository

Clone this repository, then run:

```bash
./blist-init-repo.sh /path/to/target-repo
git -C /path/to/target-repo diff
```

The installer downloads files from the `master` branch by default. Set `BASELINE_BRANCH` to select another branch. It changes the target working tree and `.gitignore`, but does not stage, commit, push, or change GitHub settings. Review downloaded files and the diff before staging. Re-running the installer updates baseline files and saves backups of changed files.

## Verify this baseline

```bash
make audit  # shell syntax and pinned action references
make scan   # Bandit Python scan; requires bandit installed
```

Bandit and TruffleHog fail their workflows when findings occur. Scorecard runs weekly and on workflow changes. The provenance workflow attests a Git source archive on release; it does not attest a built application or establish a SLSA level. Enable branch protection and GitHub security features separately in repository settings.

## Adaptation notes

Check Dependabot package ecosystems against the target repository. Adjust CodeQL languages, Bandit scope, default branch filters, CODEOWNERS identities, and disclosure contacts as needed. Avoid committing credentials, databases, logs, or model weights.
