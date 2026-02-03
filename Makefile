.PHONY: sync-skills update-skills

update-skills:
	@./scripts/update_skills.ts --file skills/sources.toml --dest skills --overwrite

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
		echo "Synced: $$skill"; \
	done < "$(CURDIR)/codex/enabled-skills"
