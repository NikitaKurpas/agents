.PHONY: sync-skills

sync-skills:
	@set -euo pipefail; \
	mkdir -p "$$HOME/.codex/skills"; \
	while IFS= read -r skill; do \
		[ -z "$$skill" ] && continue; \
		src="$(CURDIR)/skills/$$skill"; \
		dest="$$HOME/.codex/skills/$$skill"; \
		if [ ! -d "$$src" ]; then \
			echo "Missing skill directory: $$src" >&2; \
			exit 1; \
		fi; \
		rm -rf "$$dest"; \
		cp -R "$$src" "$$dest"; \
	done < "$(CURDIR)/codex/enabled-skills"
