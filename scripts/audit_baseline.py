"""Executable local baseline audit. Tool failures and malformed templates are fatal."""
import ast
from pathlib import Path
import subprocess
import sys

root = Path(__file__).resolve().parents[1]
for path in (root/'scripts').glob('*.py'):
    ast.parse(path.read_text(), filename=str(path))
subprocess.run([sys.executable, str(root/'scripts/test_check_sarif.py')], check=True)
# Workflows must not hide infrastructure failures or invoke the old nonexistent action.
for path in (root/'.github/workflows').glob('*.yml'):
    text = path.read_text()
    for forbidden in ('languages: auto', 'slsa-verifier/action@', 'build_script:', 'continue-on-error: true', '-f sarif'):
        if forbidden in text:
            raise SystemExit(f'{path.name}: obsolete/unsafe workflow setting: {forbidden}')
print('Baseline source, SARIF gate and workflow contracts passed')
