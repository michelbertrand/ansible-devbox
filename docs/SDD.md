# Software Design Document (SDD)

**Version**: 1.0  
**Last Updated**: 2026-04-29  
**Status**: Active

## 1. Design Goals

- **Idempotency**: Playbook runs are safe to repeat; no duplicate installs or unnecessary changes
- **Modularity**: Each tool is self-contained in a role with clear dependencies
- **Reproducibility**: Same playbook + inventory = identical environments across machines
- **Maintainability**: Clear role structure, defaults, and documentation
- **Extensibility**: Easy to add new roles or customize existing ones via group/host variables
- **CI-First**: Linting and validation prevent broken code from being committed

## 2. Requirements

### Functional

1. Install and configure 11 development tools (sublime_text, terminator, python, go, openjdk, maven, gradle, terraform, kubectl, minikube, ohmyzsh)
2. Support optional database roles (MySQL, MongoDB) via group variables
3. Enable/disable tools via Ansible tags
4. Provide inventory for local Ubuntu machines (connection: local)
5. Generate CI/CD pipeline to validate playbook integrity

### Non-Functional

1. **Idempotency**: Every playbook execution must be safe to re-run
2. **Performance**: Minimize unnecessary package downloads/installs
3. **Debuggability**: Verbosity flags and check mode allow dry-runs
4. **Compatibility**: Support Ubuntu 20.04+, Ansible 2.10+
5. **Security**: No hardcoded secrets; use vault/env vars for sensitive data

## 3. Architecture

### 3.1 Directory Structure

```
├── ansible/
│   ├── playbooks/           # Orchestration playbooks
│   │   ├── site.yml        # Main entry point (all roles)
│   │   ├── database.yml    # Database provisioning
│   │   └── extend_role.yml # Custom role example
│   ├── inventory/
│   │   ├── hosts.ini       # Inventory groups/hosts
│   │   └── group_vars/
│   │       ├── all.yml     # Global defaults
│   │       └── local.yml   # Local-machine overrides
│   └── roles/              # Tool roles (1 per tool)
├── docs/
│   ├── SDD.md             # This document
│   └── git-spec.md        # Workflow specification
├── .github/workflows/
│   └── ci.yml             # GitHub Actions validation
├── Makefile               # Convenience targets
└── tests/                 # Integration test playbooks
```

### 3.2 Role Structure

Each role follows Ansible standards:

```
roles/<role_name>/
├── README.md              # Role description
├── defaults/main.yml      # Default variables (lowest precedence)
├── vars/main.yml          # Hard-coded role variables
├── handlers/main.yml      # Handlers (service restart, etc.)
├── tasks/main.yml         # Tasks (main role logic)
├── meta/main.yml          # Role metadata/dependencies
└── tests/
    └── test_<role>.yml    # Test playbook
```

**Key Principle**: `defaults/main.yml` is for overridable user settings; `vars/main.yml` is for role internals.

### 3.3 Control Flow

```
site.yml
├── Pre-tasks (update cache if needed)
├── Roles (by tag)
│   ├── role: sublime_text (tag: sublime_text)
│   ├── role: terminator (tag: terminator)
│   ├── role: python (tag: python)
│   ├── role: go (tag: go)
│   ├── ... (other tools)
│   ├── role: mysql (tag: mysql, when: enable_mysql)
│   └── role: mongodb (tag: mongodb, when: enable_mongodb)
└── Post-tasks (summary)
```

Tags enable selective provisioning: `ansible-playbook site.yml --tags "python,go"` runs only those roles.

## 4. Idempotency Strategy

### 4.1 Core Principles

1. **Declarative State**: Roles describe desired state, not procedural steps
2. **Conditional Tasks**: Use `changed_when` and `when` clauses to avoid false positives
3. **Handlers**: Service restarts triggered only when relevant config changes
4. **Idempotent Modules**: Prefer `apt`, `pip`, `get_url`, `unarchive` over `shell/command`

### 4.2 Implementation

**Good Example** (idempotent):
```yaml
- name: Install Python
  apt:
    name: python3
    state: present

- name: Install pip packages
  pip:
    name: "{{ pip_packages }}"
    state: present
```

**Avoid** (not idempotent):
```yaml
- name: Install Python (shell command - dangerous)
  shell: apt-get install python3
```

### 4.3 Verification

- **On First Run**: Task reports `changed: true`
- **On Second Run**: Task reports `ok` (no change needed)
- **Dry-Run** (`--check`): Detects what would change without modifying

Test idempotency:
```bash
# First run
make apply

# Second run (should all be ok/unchanged)
make apply
```

## 5. Testing Strategy

### 5.1 Levels

1. **Linting** (`ansible-lint`): Best practices, undefined variables
2. **Syntax Check** (`--syntax-check`): YAML parsing, playbook structure
3. **Dry-Run** (`--check`): Safe test without system changes
4. **Integration Test**: Full provisioning in isolated environment (CI)

### 5.2 CI/CD Pipeline

GitHub Actions runs:
1. `ansible-lint ansible/`
2. `yamllint ansible/**/*.yml`
3. `ansible-playbook --syntax-check`
4. `ansible-playbook --check` (dry-run against example inventory)

**Failure**: Any linting/syntax failure blocks merge.

### 5.3 Local Testing

```bash
# Before committing
make lint
make test

# Dry-run against your machine
make check

# Full provisioning (safe to re-run)
make apply
```

### 5.4 Role-Level Testing

Test a single role:
```bash
ansible-playbook ansible/playbooks/site.yml \
  --inventory ansible/inventory/hosts.ini \
  --tags "python" \
  --check
```

For complex roles, create a test playbook in `tests/` directory.

## 6. Rollback and Upgrade

### 6.1 Rollback Strategy

**Idempotent by design**: If a playbook run fails or causes issues, fix the role and re-run.

```bash
# Example: Python role broke; fix tasks/main.yml
git checkout ansible/roles/python/
make apply TAGS="python"
```

**Data-bearing operations** (databases): Manual backup before role updates.

### 6.2 Upgrade Path

1. **Pin versions** in role defaults if stability is critical:
   ```yaml
   python_version: "3.10"
   go_version: "1.21.0"
   ```

2. **Test in dry-run first**:
   ```bash
   make check  # See what changes
   make apply  # Apply safely
   ```

3. **Commit version bumps** separately from other changes.

### 6.3 Handling Failed Runs

If a role fails mid-run:

1. **Check logs**: `ansible-playbook ... -vv`
2. **Fix root cause**: Update role tasks/vars
3. **Re-run**: `make apply TAGS="failed_role"` (idempotent re-run)
4. **Commit fix**: Git commit the corrected role

## 7. Variable Precedence

Ansible variable precedence (highest to lowest):

1. Inventory host variables (host_vars/<hostname>.yml)
2. Inventory group variables (group_vars/<groupname>.yml)
3. Role vars (roles/<role>/vars/main.yml)
4. Role defaults (roles/<role>/defaults/main.yml)
5. Playbook vars

**Best Practice**: Use role defaults for tool versions; override in group/host vars only when needed.

## 8. Security Considerations

- **No Secrets in Code**: Use `ansible-vault` or environment variables for passwords
- **Sudo Handling**: Configure passwordless sudo or use `--ask-become-pass`
- **SSH Keys**: Generate locally, do not commit to repo
- **Audit**: Ansible provides detailed logs of all changes

## 9. Future Enhancements

1. Docker/Podman role for containerization
2. Database backup roles for MySQL/MongoDB
3. Monitoring/logging role (Prometheus, ELK)
4. Multi-user provisioning (create dev users per role)
5. Vault integration for secret management
