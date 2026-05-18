# ansible-devbox

> Spin up a fully configured Linux developer workstation in one command.

New machine? Fresh VM? This repo provisions everything you need — editors, runtimes, container tools, Kubernetes CLI — in minutes, idempotently. Run it again and nothing breaks.

## What Gets Installed

| Category        | Tools                                             |
|-----------------|---------------------------------------------------|
| Shell           | zsh, Oh My Zsh, kube-ps1                         |
| Editors         | Sublime Text                                      |
| Terminals       | Terminator                                        |
| Runtimes        | Python, Go, OpenJDK                               |
| Build tools     | Maven, Gradle                                     |
| Containers      | Docker, Minikube                                  |
| Kubernetes      | kubectl, kube-ps1                                 |
| Infrastructure  | Terraform                                         |
| Databases       | MySQL, MongoDB (opt-in)                           |

## Overview

This repository provides a modular, idempotent Ansible framework for provisioning and maintaining a consistent Linux development environment on any Debian-based distribution. Each tool is isolated in its own role, enabling selective installation, updates, and testing.

**Why Ansible?** Shell scripts break. Ansible roles are idempotent — you can run this on an existing machine and it only changes what's missing or out of date. No surprises, no side effects.

## Features

- **Idempotent roles**: Run playbooks multiple times with no side effects
- **Per-tool roles**: Git, Sublime Text, Terminator, Python, Go, OpenJDK, Maven, Gradle, Terraform, kubectl, Minikube, Docker, Oh My Zsh
- **Optional databases**: MySQL and MongoDB configurable via group variables
- **CI/CD ready**: GitHub Actions linting, syntax checking, and dry-run testing
- **Comprehensive documentation**: SDD, git-spec, and per-role READMEs
- **Testing framework**: Per-role test playbooks under `tests/`

## Quick Start

### Prerequisites

- Any Debian-based Linux distribution (Ubuntu 20.04+, Linux Mint, Pop!\_OS, Debian 11+, or equivalent)
- Ansible 2.10+
- GNU Make
- sudo access (passwordless preferred for automation)

> **Note:** The roles rely on `apt` for package management, so any distribution that ships with `apt` and bash is compatible.

```bash
# Install required tools if not already present (apt-based systems)
sudo apt-get update && sudo apt-get install -y ansible make

# Clone and navigate to repo
git clone <repo-url>
cd ansible-devbox
```

### Basic Usage

```bash
# Dry-run: see what would change
make check

# Apply all roles (provisioning)
make apply

# Apply specific role(s)
ansible-playbook ansible/playbooks/site.yml \
  --inventory ansible/inventory/hosts.ini \
  --tags "python,go" \
  --ask-become-pass

# Check syntax (no sudo needed)
make lint
```

**Note:** Roles install system packages via Ansible's `become: true`. Configure passwordless sudo for the provisioning commands (see Troubleshooting), or pass `--ask-become-pass` to be prompted. Never run `sudo make` — that elevates the entire Make process unnecessarily.

### Makefile Targets

```bash
make lint         # Run ansible-lint and yamllint
make test         # Run syntax checks and dry-run
make apply        # Apply playbook (provision)
make check        # Dry-run without changes
make role-create  # Scaffold a new role (interactive)
```

## Repository Structure

```
.
├── README.md
├── Makefile
├── LICENSE
├── .gitignore
├── docs/
│   ├── SDD.md              # Software Design Document
│   └── git-spec.md         # Git workflow specification
├── ansible/
│   ├── playbooks/
│   │   ├── site.yml        # Main playbook
│   │   ├── database.yml    # Database provisioning examples
│   │   └── extend_role.yml # Custom role example
│   ├── inventory/
│   │   ├── hosts.ini       # Local inventory
│   │   └── group_vars/
│   │       ├── all.yml     # Global variables
│   │       └── local.yml   # Local host variables
│   └── roles/
│       ├── git/
│       ├── sublime_text/
│       ├── terminator/
│       ├── ohmyzsh/
│       ├── python/
│       ├── go/
│       ├── openjdk/
│       ├── maven/
│       ├── gradle/
│       ├── terraform/
│       ├── kubectl/
│       ├── docker/
│       ├── minikube/
│       ├── mysql/ (optional)
│       └── mongodb/ (optional)
├── .github/
│   └── workflows/
│       └── ci.yml         # CI/CD pipeline
└── CODEOWNERS
```

## Example Playbooks

### Configure Git Identity

Copy the example file and edit it (never commit `local.yml` — it is gitignored):

```bash
cp ansible/inventory/group_vars/local.yml.example \
   ansible/inventory/group_vars/local.yml
```

Then set your identity in `local.yml`:

```yaml
git_user_name: "Your Name"
git_user_email: "you@example.com"
```

Then apply just the git role:

```bash
make apply TAGS="git"
```

### Enable Optional Databases

Edit `ansible/inventory/group_vars/local.yml` (gitignored — do not commit):

```yaml
# Enable MySQL — set a strong password here; never commit this file
enable_mysql: true
mysql_root_password: "your-secure-password"

# Enable MongoDB
enable_mongodb: true
```

Run the database provisioning:

```bash
ansible-playbook ansible/playbooks/database.yml \
  --inventory ansible/inventory/hosts.ini \
  --tags mysql,mongodb
```

### Selective Provisioning

Provision only specific tools:

```bash
make apply TAGS="python,terraform,kubectl"
# Or directly:
ansible-playbook ansible/playbooks/site.yml \
  --inventory ansible/inventory/hosts.ini \
  --tags "python,terraform,kubectl"
```

### Re-run Idempotently

Re-provision without reinstalling (checks/updates only):

```bash
make check  # View changes (dry-run)
make apply  # Apply changes
```

## Troubleshooting

### Common Issues

**Q: Playbook fails with "Permission denied" or "interactive authentication is required"**
- All provisioning commands require `sudo` privileges. Use:
  - `sudo make check` or `sudo make apply`
  - Or: `ansible-playbook ... --ask-become-pass` to be prompted for password
- For passwordless sudo: add your user to sudoers with NOPASSWD (see docs/SDD.md)

**Q: Roles not found error**
- Ensure `ansible.cfg` exists in the project root (should be present in repo)
- Verify roles_path is set correctly: `cat ansible.cfg | grep roles_path`
- Run from project root directory: `cd ansible-devbox && make check`

**Q: Role shows "changed" on every run (not idempotent)**
- Check handlers in the role; verify `changed_when` conditions
- See docs/SDD.md for idempotency strategy details
- Test role in isolation: `sudo ansible-playbook ansible/playbooks/site.yml --tags "role_name" --check`

**Q: Specific tool version mismatch**
- Edit role defaults: `ansible/roles/<role>/defaults/main.yml`
- Pin versions in the role vars or inventory `group_vars/local.yml`
- For roles with pinned checksums (terraform, gradle), update `<tool>_checksum` alongside the version

**Q: Dry-run shows changes but apply doesn't**
- Idempotent behavior is expected; first run makes changes, second run is clean
- Verify by running again: `make check` should show "ok" status on re-run

### Re-running Idempotently

```bash
# View what changed in last run
ansible-playbook ansible/playbooks/site.yml \
  --inventory ansible/inventory/hosts.ini \
  -v

# Force re-download/reinstall for a role
ansible-playbook ansible/playbooks/site.yml \
  --inventory ansible/inventory/hosts.ini \
  --tags "go" \
  --extra-vars "force_reinstall=true"
```

## CI/CD

The `.github/workflows/ci.yml` runs on push/PR with four sequential stages:

1. **Linting** — `ansible-lint` + `yamllint`
2. **Syntax check** — `ansible-playbook --syntax-check`
3. **Molecule tests** — all 16 roles run in parallel Docker containers (converge + verify)
4. **Dry-run** — `ansible-playbook --check` against the local inventory (non-blocking)

Molecule jobs run in parallel using a matrix strategy; a single role failure does not cancel the others (`fail-fast: false`). Address linter or molecule failures before merging.

## Security

### Binary Verification (NFR-3.5.1)

All binaries downloaded via `get_url` must include a `checksum:` field. A checksum mismatch causes the task to fail immediately. SHA256 checksums are maintained in each role's variables and must be updated alongside version bumps:

```yaml
# ansible/roles/terraform/defaults/main.yml
terraform_version: "1.9.0"
terraform_checksum: "sha256:<hash>"
```

Roles affected: `terraform`, `kubectl`, `minikube`.

### Package Source Verification (NFR-3.5.2)

Only official APT repositories are permitted. Every third-party repository added by a role must:

- Import its GPG signing key via the `ansible.builtin.apt_key` module (or `get_url` + `apt_key`)
- Be added with a pinned `signed-by=` path in the `.list` / `.sources` entry
- Never use `allow_unauthenticated: true`

Unsigned or unverifiable repositories will cause CI to fail via `ansible-lint`.

### No Hardcoded Secrets (NFR-3.5.3)

Sensitive values (database passwords, API keys, private keys) must **never** appear in playbooks, role defaults, or inventory files committed to the repository:

- Use `ansible-vault encrypt_string` for secrets stored in-repo
- Accept passwords at runtime with `vars_prompt` or `--extra-vars`
- Database roles default to `""` for passwords; provisioning fails explicitly if unset
- Sensitive variables must be marked `no_log: true` in any task that prints them

### Least Privilege (NFR-3.5.4)

Privilege escalation (`become: true`) is restricted to tasks that strictly require it:

- System package installation (`apt`, `snap`)
- Writing to `/usr/local/bin`, `/opt`, or `/etc`
- Service management (`systemd`)

User-space operations (dotfile writes, shell config, `~/.config/**`) run without `become`. Never invoke `sudo make` — escalate individual tasks within the playbook instead.

---

## Development

### Creating a New Role

```bash
make role-create

# Or manually:
ansible-galaxy role init --init-path ansible/roles/ my_role
```

Use role templates in `ansible/roles/*/` as examples for structure.

### Testing Roles

Every role ships a Molecule scenario under `molecule/default/` that spins up a Docker container, converges the role, and verifies the result. Run any role's tests in isolation:

```bash
# Install Molecule (once)
pip install 'ansible>=10.0,<11.0' 'molecule>=6.0,<7.0' 'molecule-plugins[docker]'

# Run full test cycle for a role (create → converge → verify → destroy)
cd ansible/roles/python
molecule test

# Converge only (faster iteration)
molecule converge

# Verify only (after a converge)
molecule verify
```

Roles that start system services (docker, mysql, mongodb) use a privileged systemd container image; all other roles use a standard Ubuntu 24.04 image.

For dry-run syntax testing without Docker:

```bash
# Dry-run a single role
ansible-playbook ansible/playbooks/site.yml \
  --inventory ansible/inventory/hosts.ini \
  --tags "python" --check
```

## Contributing

See `docs/git-spec.md` for branch model, commit conventions, and PR guidelines.

## License

MIT License - See LICENSE file.

## Support

For issues, questions, or contributions, refer to the CODEOWNERS file or open an issue in the repository.
