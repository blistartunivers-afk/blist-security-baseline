# Security Policy

## Reporting a vulnerability

Do not open a public issue containing a vulnerability or credentials. Use GitHub's **Report a vulnerability** option in the affected repository's Security tab to submit a private report. If that option is unavailable, contact the repository maintainers through an established private channel and ask them to enable private reporting; do not send exploit details through a public issue.

Include the affected repository and version, a concise description, reproduction steps, and the potential impact. Avoid including live credentials or personal data.

Maintainers should acknowledge reports, investigate privately, coordinate fixes and disclosure with the reporter, and publish a security advisory when appropriate. Response times depend on maintainer availability and severity; this template does not promise a fixed service level.

## Applying this template

Verify the reporting route in the target repository before installing this policy. Enable private vulnerability reporting and branch protection in GitHub settings where available. `CODEOWNERS` identifies requested reviewers; it does not enforce approval by itself.

Keep credentials out of Git. Review workflow permissions and pinned action revisions when updating the baseline. The source archive provenance workflow records the archive's origin; it does not attest deployed artifacts.
