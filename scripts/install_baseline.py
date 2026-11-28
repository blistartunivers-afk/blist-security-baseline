"""Plan/apply local baseline files without committing or changing GitHub settings."""
import argparse
from datetime import datetime, timezone
from pathlib import Path
import shutil
import subprocess


def install(source: Path, target: Path, *, apply: bool = False, overwrite: bool = False) -> list[str]:
    source, target = source.resolve(), target.resolve()
    top = Path(subprocess.check_output(['git', '-C', str(target), 'rev-parse', '--show-toplevel'], text=True).strip()).resolve()
    if top != target:
        raise ValueError('Target must be the repository root')
    paths = [str(p.relative_to(source)) for p in (source/'.github/workflows').glob('*.yml')]
    paths += ['.github/dependabot.yml', '.pre-commit-config.yaml', '.pinact.yaml',
              'Makefile', 'SECURITY.md', 'CODEOWNERS', 'scripts/check_sarif.py', 'scripts/test_check_sarif.py',
              'scripts/audit_baseline.py', 'scripts/check_bandit.py', 'scripts/summarize_secrets.py', 'scripts/install_baseline.py', 'docs/CI_SECURITY.md']
    changes = []
    for name in sorted(paths):
        src, dst = source/name, target/name
        if not src.is_file():
            raise ValueError(f'Missing baseline source: {name}')
        if dst.is_symlink() or not dst.resolve().is_relative_to(target):
            raise ValueError(f'Refusing symlink destination: {name}')
        if dst.exists() and dst.read_bytes() == src.read_bytes(): continue
        if apply and dst.exists() and not overwrite:
            raise ValueError(f'{name} already exists; inspect plan and use --overwrite explicitly')
        changes.append(name)
    if not apply: return changes
    backup = target/'.blist-baseline-backups'/datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%S%fZ')
    written = []
    try:
        for name in changes:
            dst = target/name
            existed = dst.exists()
            if existed:
                (backup/name).parent.mkdir(parents=True, exist_ok=True)
                (backup/".gitignore").write_text("*\n")
                shutil.copy2(dst, backup/name)
            dst.parent.mkdir(parents=True, exist_ok=True)
            written.append((name, existed))
            shutil.copy2(source/name, dst)
    except Exception:
        for name, existed in reversed(written):
            if existed: shutil.copy2(backup/name, target/name)
            else: (target/name).unlink(missing_ok=True)
        raise
    return changes


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('target', type=Path)
    parser.add_argument('--apply', action='store_true')
    parser.add_argument('--overwrite', action='store_true')
    args = parser.parse_args()
    changes = install(Path(__file__).resolve().parents[1], args.target, apply=args.apply, overwrite=args.overwrite)
    print(('Applied' if args.apply else 'Plan only') + ':')
    print('\n'.join(changes) or 'No changes')
    print('No Git index, commits, branch protections or remote settings were changed.')


if __name__ == '__main__': main()
