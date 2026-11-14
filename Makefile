# BLIST Security Makefile
.PHONY: scan audit help

help:
	@echo "BLIST Security Tools"
	@echo "  make scan    - Run Bandit (Python SAST)"
	@echo "  make audit   - Check shell syntax and action pins"

scan:
	@echo "[*] Running Bandit SAST..."
	@bandit -r .

audit:
	@bash -n blist-init-repo.sh
	@python3 scripts/check_action_pins.py
