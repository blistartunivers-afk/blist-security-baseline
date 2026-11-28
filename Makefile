# Commands propagate errors; audit never mutates repositories or GitHub settings.
.PHONY: scan audit help
help:
	@echo "make scan: Bandit source analysis; make audit: executable baseline checks"
scan:
	bandit -r scripts -f json -o bandit-results.json
audit:
	python3 scripts/audit_baseline.py
