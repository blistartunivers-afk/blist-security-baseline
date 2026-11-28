# BLIST Security Baseline

Reusable security workflows and a local installer that preserves existing work.
CI validates execution and report integrity; a green job is not a certification
of a running service or proof that all reported findings are resolved.

## Installation

Clone this repository so the installer and its templates are available together:

```bash
git clone https://github.com/blistartunivers-afk/blist-security-baseline.git
python3 blist-security-baseline/scripts/install_baseline.py /path/to/target-repo
```

The command prints a plan without changing the target. Review language selection,
project-specific tests and existing workflow names before applying:

```bash
python3 blist-security-baseline/scripts/install_baseline.py /path/to/target-repo --apply
```

Existing files with different contents require `--overwrite`. Originals are kept
under `.blist-baseline-backups/` with a local ignore file. The installer never stages
files, creates commits, modifies branches, downloads mutable templates or changes
GitHub protections. Review and commit the resulting diff through the target's
normal process. Do not pipe a standalone copy of the shell wrapper from curl.

## Controls

- Bandit JSON is preserved; installation, execution and parse failures are fatal.
  Findings remain available for review, separately from infrastructure failures.
- Scorecard resolves explicit and inherited SARIF levels. Error findings are not
  silently ignored. Licenses, external fuzzing integration and other repository
  posture items can require maintainer decisions beyond a source patch.
- Pin Actions checks immutable references for every PR. The exact SLSA v2.1.0 tag
  exception is documented because the builder validates its tag identity.
- The checksum-pinned secret scanner examines history without calling providers.
  Only detector counters appear in logs. Removed literals can still require
  revocation/rotation; raw values are not uploaded as artifacts.
- CodeQL uses explicit languages. Private repositories need entitlement and
  `ENABLE_PRIVATE_CODEQL=true`; an unavailable analysis is explicitly skipped.
- Public manual/release provenance builds and verifies a real source archive.
  It does not certify compiled binaries. Private code is not sent to a public
  transparency log. See [CI configuration](docs/CI_SECURITY.md).

## Local validation

```bash
make audit
python3 scripts/test_install_baseline.py
make scan
```

`make audit` validates baseline source, workflow contracts and the SARIF gate.
`make scan` executes Bandit and propagates its status. Neither command changes
remote settings or live agent state.

[Security reporting](SECURITY.md) · [MIT license](LICENSE)
