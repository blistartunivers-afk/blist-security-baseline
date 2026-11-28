#!/usr/bin/env bash
# Clone this baseline first. Plan by default; --apply and --overwrite are explicit.
set -euo pipefail
script_dir="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
exec python3 "$script_dir/scripts/install_baseline.py" "$@"
