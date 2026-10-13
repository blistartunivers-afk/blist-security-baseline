# BLIST Security Makefile
.PHONY: scan audit clean help

help:
	@echo "BLIST Security Tools"
	@echo "  make scan    - Run Bandit (Python SAST)"
	@echo "  make audit   - Full system security audit"

scan:
	@echo "[*] Running Bandit SAST..."
	@bandit -r . || echo "[!] Bandit found issues or is not installed"

audit:
	@echo "[*] Running BLIST Security Audit..."
	@python3 -c "print('Audit logic placeholder')"
