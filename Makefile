.PHONY: help lint test apply check role-create clean

ANSIBLE_CMD := ansible-playbook
INVENTORY := ansible/inventory/hosts.ini
PLAYBOOK := ansible/playbooks/site.yml
EXTRA_VARS ?=
TAGS ?=

help:
	@echo "Ubuntu Dev Environment - Ansible Provisioning"
	@echo ""
	@echo "Targets:"
	@echo "  make lint        - Run ansible-lint and yamllint"
	@echo "  make test        - Run syntax checks and dry-run"
	@echo "  make apply       - Provision the environment (changes system)"
	@echo "  make check       - Dry-run without making changes"
	@echo "  make role-create - Scaffold a new role"
	@echo "  make clean       - Remove Ansible artifacts"
	@echo ""
	@echo "Options:"
	@echo "  TAGS=<tag>       - Run only specific tags (e.g., make apply TAGS=python,go)"
	@echo "  EXTRA_VARS=<var> - Pass extra variables to Ansible"
	@echo ""
	@echo "Examples:"
	@echo "  make check                           # Dry-run all roles"
	@echo "  make apply TAGS=python,terraform     # Provision Python and Terraform only"
	@echo "  make apply EXTRA_VARS='force_reinstall=true' # Force reinstall"

lint:
	@echo "Running ansible-lint..."
	@ansible-lint ansible/ || (echo "ansible-lint checks failed"; exit 1)
	@echo "Running yamllint..."
	@yamllint -d '{extends: default, rules: {line-length: {max: 120}}}' \
		ansible/playbooks/*.yml \
		ansible/inventory/*.yml \
		ansible/inventory/group_vars/*.yml \
		ansible/roles/*/defaults/main.yml \
		ansible/roles/*/vars/main.yml || (echo "yamllint checks failed"; exit 1)
	@echo "✓ All linting passed"

test:
	@echo "Running syntax check..."
	@$(ANSIBLE_CMD) $(PLAYBOOK) --inventory $(INVENTORY) --syntax-check
	@echo "Running dry-run..."
	@$(ANSIBLE_CMD) $(PLAYBOOK) --inventory $(INVENTORY) --check
	@echo "✓ All syntax checks and dry-run passed"

apply:
	@echo "Provisioning environment..."
	@$(ANSIBLE_CMD) $(PLAYBOOK) \
		--inventory $(INVENTORY) \
		$(if $(TAGS),--tags "$(TAGS)") \
		$(if $(EXTRA_VARS),--extra-vars "$(EXTRA_VARS)")

check:
	@echo "Running dry-run (no changes)..."
	@$(ANSIBLE_CMD) $(PLAYBOOK) \
		--inventory $(INVENTORY) \
		--check \
		$(if $(TAGS),--tags "$(TAGS)") \
		$(if $(EXTRA_VARS),--extra-vars "$(EXTRA_VARS)")

role-create:
	@read -p "Enter role name: " ROLE_NAME; \
	if [ -z "$$ROLE_NAME" ]; then \
		echo "Role name required"; exit 1; \
	fi; \
	ansible-galaxy role init --init-path ansible/roles/ "$$ROLE_NAME"; \
	echo "✓ Role '$$ROLE_NAME' created at ansible/roles/$$ROLE_NAME/"

clean:
	@find ansible/ -name "*.retry" -delete
	@find ansible/roles -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	@echo "✓ Cleanup complete"
