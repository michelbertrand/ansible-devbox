# Project Specification: Personal Development Environment

## 1. Project Overview

**Project Name:** Personal Development Environment (PDE)  
**Version:** 1.0.0  
**Status:** In Development  
**Last Updated:** 2026-05-11

**Purpose:** Establish a reproducible, idempotent, and maintainable local development environment on Ubuntu that provisions and maintains a complete software development toolkit through Infrastructure as Code using Ansible.

**Scope:** Automated provisioning, configuration, and maintenance of a developer workstation with support for multiple programming languages, container orchestration, build tools, and optional database services.

---

## 2. Functional Requirements

### 2.1 Environment Provisioning

#### FR-2.1.1: Ubuntu System Setup
- **Requirement:** The system must detect and run on Ubuntu 20.04 LTS or later (focal, jammy, noble).
- **Description:** Ansible playbooks shall validate OS version and fail gracefully if OS is unsupported.
- **Acceptance Criteria:**
  - Playbook executes without errors on Ubuntu 20.04, 22.04, and 24.04
  - Explicit error message if OS is not Ubuntu or version is unsupported

#### FR-2.1.2: Package Management System Setup
- **Requirement:** System package manager (apt) must be updated and optimized.
- **Description:** Ensure package cache is current and dependencies are resolved correctly.
- **Acceptance Criteria:**
  - `apt update` runs and completes successfully
  - No broken package dependencies remain after provisioning
  - All required system libraries are installed before tool installation

#### FR-2.1.3: Tool Installation via Native Packages
- **Requirement:** Install core tools using apt, snap, or official package managers.
- **Description:** Prioritize native package managers over shell scripts where available.
- **Acceptance Criteria:**
  - Git provisioned with global configuration (user name, email, default branch, aliases)
  - Sublime Text Editor provisioned and executable
  - Terminator terminal emulator provisioned and executable
  - Python 3.x provisioned with pip
  - Go installed and GOPATH configured
  - OpenJDK provisioned and JAVA_HOME set
  - Maven provisioned and ready for use
  - Gradle provisioned and ready for use
  - Terraform provisioned and executable
  - Kubectl provisioned and executable
  - Minikube provisioned and executable
  - OhMyZsh installed with zsh as shell

#### FR-2.1.4: Tool Installation via Binary Download
- **Requirement:** Install tools that are not available in standard repositories via controlled binary downloads.
- **Description:** Use Ansible modules (get_url, unarchive) to download and extract binaries from official sources with checksum verification.
- **Acceptance Criteria:**
  - Terraform binary verified with checksum
  - Kubectl binary verified with checksum
  - Minikube binary verified with checksum
  - All binaries extracted to proper PATH locations

#### FR-2.1.5: Tool Versioning and Updates
- **Requirement:** Each tool shall have a configurable default version via Ansible variables.
- **Description:** Role defaults/main.yml must define versions; playbook must support version overrides at runtime.
- **Acceptance Criteria:**
  - Each role exposes a version variable (e.g., terraform_version)
  - Version variable can be overridden via inventory or command-line
  - Tool reports correct version after installation

#### FR-2.1.6: Shell Environment Configuration
- **Requirement:** Configure shell environment variables for installed tools.
- **Description:** Set JAVA_HOME, GOPATH, GRADLE_HOME, etc. in shell initialization files (~/.zshrc, ~/.bashrc).
- **Acceptance Criteria:**
  - JAVA_HOME points to OpenJDK installation
  - GOPATH configured and in PATH
  - Maven bin directory in PATH
  - Gradle bin directory in PATH
  - PATH updated to include all tool binaries
  - Environment variables persist across shell sessions

### 2.2 Idempotency and Repeatability

#### FR-2.2.1: Idempotent Execution
- **Requirement:** Running the playbook multiple times on the same system must produce the same result without errors or unwanted modifications.
- **Description:** All Ansible tasks must be idempotent; repeated runs shall not fail or reinstall working tools.
- **Acceptance Criteria:**
  - First run: installs all tools and reports changes
  - Second run: reports no changes or only handlers
  - No tasks fail on repeated execution
  - No warning messages on repeated execution

#### FR-2.2.2: Conditional Installation
- **Requirement:** Skip installation if a tool is already present and at the desired version.
- **Description:** Use package facts, file stat checks, and command output to determine installation status.
- **Acceptance Criteria:**
  - Ansible facts determine if package is installed
  - Version check prevents downgrade if newer version exists
  - File checks for tool binaries before downloading
  - Custom facts cache tool versions for efficiency

#### FR-2.2.3: Observable State Changes
- **Requirement:** Tasks must use `changed_when` to accurately report state changes.
- **Description:** Only report "changed" when the system state actually changes, not on every task execution.
- **Acceptance Criteria:**
  - Package install tasks only report changed when new packages installed
  - Configuration file tasks report changed only when content modified
  - Handlers only trigger when dependent task changed

#### FR-2.2.4: Rollback and Idempotent Fixes
- **Requirement:** System state must be recoverable without manual intervention.
- **Description:** Playbook must support re-running to fix broken states or restore default configurations.
- **Acceptance Criteria:**
  - Re-running playbook fixes missing or corrupted configurations
  - Configuration files can be restored to defaults
  - No manual cleanup required before re-running

### 2.3 Configuration and Customization

#### FR-2.3.1: Environment Defaults
- **Requirement:** Each role must define sensible defaults for versions, paths, and options.
- **Description:** defaults/main.yml in each role contains standard, tested configurations.
- **Acceptance Criteria:**
  - All roles have defaults/main.yml file
  - Defaults specify tool versions, installation paths, and key options
  - Playbook runs successfully with default values without customization

#### FR-2.3.2: Group Variables and Inventory Customization
- **Requirement:** Users can override tool versions and enable/disable optional components via inventory.
- **Description:** Use Ansible group_vars and host_vars for customization; optional roles configurable via flags.
- **Acceptance Criteria:**
  - group_vars/all.yml defines global settings
  - group_vars/local.yml overrides for local environment
  - Optional roles (MySQL, MongoDB) can be enabled/disabled via group_vars
  - Inventory variables override defaults

#### FR-2.3.3: Optional Database Provisioning
- **Requirement:** MySQL and MongoDB must be optionally installable via group_vars configuration.
- **Description:** Two optional Ansible roles (mysql, mongodb) that install and configure databases; enabled only when specified.
- **Acceptance Criteria:**
  - mysql_enabled: true/false controls MySQL installation
  - mongodb_enabled: true/false controls MongoDB installation
  - MySQL role installs MySQL server, configures service, sets root password
  - MongoDB role installs MongoDB server, configures service
  - Databases are disabled by default but easily enabled
  - Example playbook demonstrates enabling/disabling databases

#### FR-2.3.4: Role Extensibility
- **Requirement:** Users can easily create custom roles to extend the environment.
- **Description:** Provide role template and Makefile target for creating new roles with correct structure.
- **Acceptance Criteria:**
  - Makefile target `role-create ROLE=myapp` scaffolds new role
  - New role has standard directory structure (tasks/, handlers/, defaults/, etc.)
  - Documentation explains how to extend the environment

### 2.4 Container and Orchestration Support

#### FR-2.4.1: Kubernetes Local Development
- **Requirement:** Kubectl and Minikube installed to enable local Kubernetes development.
- **Description:** Kubectl configured to work with Minikube; both tools available for container orchestration testing.
- **Acceptance Criteria:**
  - kubectl installed and executable
  - kubectl version command succeeds
  - Minikube installed and executable
  - Minikube can start a local cluster (post-installation validation)
  - kubeconfig properly configured for Minikube

#### FR-2.4.2: Infrastructure as Code Tools
- **Requirement:** Terraform installed for IaC development and validation.
- **Description:** Terraform provisioned and ready for writing and testing infrastructure code.
- **Acceptance Criteria:**
  - Terraform installed and executable
  - terraform version command succeeds
  - terraform init/validate can be run on sample configurations

### 2.5 Terminal and Editor Environment

#### FR-2.5.1: Terminal Emulator
- **Requirement:** Terminator terminal emulator provisioned for advanced terminal features.
- **Description:** Terminator installed as primary terminal with customizable layouts and features.
- **Acceptance Criteria:**
  - Terminator installed and launchable
  - Terminator configuration directory created (~/.config/terminator/)
  - Terminator configurations applied (profiles, layouts, colors)

#### FR-2.5.2: Code Editor
- **Requirement:** Sublime Text Editor installed as primary code editor.
- **Description:** Sublime Text provisioned with package management ready (Sublime Package Control).
- **Acceptance Criteria:**
  - Sublime Text installed and executable
  - Sublime configuration directory created (~/.config/sublime-text/)
  - Sublime Text ready for package installation

#### FR-2.5.3: Shell Enhancement
- **Requirement:** OhMyZsh installed with auto-completion and plugins enabled.
- **Description:** Zsh with OhMyZsh framework provides enhanced shell features, auto-completion, and plugins.
- **Acceptance Criteria:**
  - Zsh installed
  - OhMyZsh framework installed
  - .zshrc configured with plugins (git, completion, etc.)
  - Auto-completion works for installed tools (kubectl, docker, etc.)
  - Default shell changed to zsh

---

## 3. Non-Functional Requirements

### 3.1 Performance

#### NFR-3.1.1: Installation Time
- **Requirement:** Full environment provisioning shall complete within 30 minutes on a typical development machine.
- **Description:** All tools installed and configured efficiently without unnecessary delays.
- **Acceptance Criteria:**
  - Fresh system provisioning completes in < 30 minutes
  - Package downloads parallelized where possible
  - No long-running sequential operations without justification

#### NFR-3.1.2: Repeated Execution Efficiency
- **Requirement:** Re-running playbook on a fully provisioned system shall complete within 2 minutes.
- **Description:** Idempotent checks and skip conditions minimize unnecessary work.
- **Acceptance Criteria:**
  - Second playbook run completes in < 2 minutes with no changes
  - No package manager operations when all packages installed
  - Fact gathering cached efficiently

### 3.2 Reliability and Robustness

#### NFR-3.2.1: Error Handling
- **Requirement:** Playbook must gracefully handle common error conditions and provide diagnostic information.
- **Description:** Tasks fail safely with clear error messages; users can resolve issues without ambiguity.
- **Acceptance Criteria:**
  - Missing dependencies identified with clear error messages
  - Network errors during downloads caught and reported
  - Incompatible OS versions detected and reported explicitly
  - Task failures include remediation suggestions in output

#### NFR-3.2.2: Dependency Management
- **Requirement:** All tool dependencies explicitly declared and installed before dependent tools.
- **Description:** Role metadata (meta/main.yml) declares role dependencies; roles execute in correct order.
- **Acceptance Criteria:**
  - Each role declares dependencies in meta/main.yml
  - Ansible respects role dependency order
  - No "tool not found" errors due to missing dependencies
  - Transitive dependencies resolved automatically

#### NFR-3.2.3: Network Resilience
- **Requirement:** Playbook must handle temporary network failures gracefully.
- **Description:** Retries and timeouts configured for network operations; fallback mirrors supported where applicable.
- **Acceptance Criteria:**
  - get_url and apt tasks configured with retries
  - Network timeouts set reasonably (30-60 seconds)
  - Clear error messages if network unavailable after retries

### 3.3 Maintainability

#### NFR-3.3.1: Code Documentation
- **Requirement:** All Ansible roles, playbooks, and configurations must be documented.
- **Description:** Each role includes README.md with purpose, variables, and examples.
- **Acceptance Criteria:**
  - Each role has README.md documenting variables and usage
  - Playbook files include comments explaining complex logic
  - Variable naming conventions consistent across roles
  - All handlers documented with their purpose

#### NFR-3.3.2: Version Control and CI/CD
- **Requirement:** Repository follows git best practices with automated validation.
- **Description:** GitHub Actions pipeline validates code quality before merge.
- **Acceptance Criteria:**
  - ansible-lint runs and passes on all changes
  - yamllint validates YAML syntax
  - ansible-playbook --syntax-check passes
  - Dry-run (--check mode) validates playbook logic
  - CI fails fast on linter errors
  - CODEOWNERS enforces review policies

#### NFR-3.3.3: Testing and Validation
- **Requirement:** Roles must be testable with included test suites.
- **Description:** Each role includes simple validation playbooks under tests/.
- **Acceptance Criteria:**
  - Each role has tests/ directory with test playbook
  - Tests validate tool installation and basic functionality
  - Tests can be run independently per role
  - Makefile test target runs all tests

#### NFR-3.3.4: Documentation Quality
- **Requirement:** Project documentation must be comprehensive and accessible.
- **Description:** README.md, SDD.md, git-spec.md, and troubleshooting guide provide complete reference.
- **Acceptance Criteria:**
  - README.md includes quick-start and usage examples
  - SDD.md explains architecture and design decisions
  - git-spec.md documents development workflow
  - Troubleshooting guide covers common issues and solutions
  - All documentation in markdown with consistent formatting

### 3.4 Portability and Compatibility

#### NFR-3.4.1: Ubuntu Version Compatibility
- **Requirement:** Playbook must support Ubuntu 20.04 LTS, 22.04 LTS, and 24.04 LTS.
- **Description:** Ansible roles use conditional logic for version-specific package names or installation methods.
- **Acceptance Criteria:**
  - Playbook detects Ubuntu version
  - Version-specific packages used (e.g., python3.11 vs python3.10)
  - CI tests on multiple Ubuntu versions
  - Graceful failure on unsupported versions

#### NFR-3.4.2: System Architecture Support
- **Requirement:** Playbook supports x86_64 and ARM64 (aarch64) architectures.
- **Description:** Tools installed with correct binaries for system architecture; multi-arch testing performed.
- **Acceptance Criteria:**
  - Architecture detection in Ansible facts
  - Correct binary downloads for x86_64 and ARM64
  - Tests validate on both architectures where applicable

#### NFR-3.4.3: Idempotent Tool Updates
- **Requirement:** Updating tool versions via playbook shall not corrupt existing configurations.
- **Description:** Version updates handled safely without breaking existing settings.
- **Acceptance Criteria:**
  - Tool version updates don't reset configurations
  - Existing customizations preserved during updates
  - No manual cleanup required before version updates

### 3.5 Security

#### NFR-3.5.1: Binary Verification
- **Requirement:** Downloaded binaries must be verified with checksums to ensure integrity.
- **Description:** All get_url operations include checksum validation.
- **Acceptance Criteria:**
  - Terraform binary verified with checksum
  - Kubectl binary verified with checksum
  - Minikube binary verified with checksum
  - SHA256 checksums maintained in role variables
  - Checksum mismatch causes task failure

#### NFR-3.5.2: Package Source Verification
- **Requirement:** Package sources must be authenticated and from official repositories only.
- **Description:** Uses official Ubuntu repositories and package signing keys.
- **Acceptance Criteria:**
  - Only official APT repositories configured
  - GPG keys for repositories validated
  - No third-party or unsigned repositories
  - Package source changes logged for auditability

#### NFR-3.5.3: No Hardcoded Secrets
- **Requirement:** Playbook shall not contain hardcoded credentials or sensitive data.
- **Description:** All sensitive configuration (passwords, keys) handled securely or left to user configuration.
- **Acceptance Criteria:**
  - No passwords in playbook or defaults
  - Database passwords configurable via vault or runtime input
  - Private keys handled securely
  - Sensitive data never logged

#### NFR-3.5.4: Least Privilege Installation
- **Requirement:** Tools installed with minimal required privileges; sudo used only when necessary.
- **Description:** Installation uses necessary privilege escalation but avoids unnecessary root access.
- **Acceptance Criteria:**
  - sudo used only for system package operations
  - User directories not accessed with elevated privileges
  - File permissions set correctly for tool operation

### 3.6 Usability

#### NFR-3.6.1: Clear User Interface
- **Requirement:** Playbook output must be clear and actionable for users.
- **Description:** Ansible output includes progress indicators, task descriptions, and error messages.
- **Acceptance Criteria:**
  - Task names clearly describe what is being done
  - Progress output shows which tools are being installed
  - Error messages include remediation suggestions
  - Color-coded output (if terminal supports) for easy scanning

#### NFR-3.6.2: Simplified Commands
- **Requirement:** Common operations accessible via simple Makefile targets.
- **Description:** Make targets provide shortcuts for common operations.
- **Acceptance Criteria:**
  - `make apply` provisions environment
  - `make check` performs dry-run
  - `make lint` validates code
  - `make test` runs all tests
  - `make help` shows all available targets

#### NFR-3.6.3: Quick Start Guide
- **Requirement:** Users must be able to start using environment within 5 minutes.
- **Description:** Clear, concise quick-start documentation provided.
- **Acceptance Criteria:**
  - Quick-start section in README.md
  - Step-by-step instructions provided
  - Example commands can be copy-pasted
  - Typical installation completed within stated time

---

## 4. Quality Attributes

### 4.1 Consistency
- All roles follow the same directory structure and naming conventions
- Variables named consistently across roles (e.g., `<role>_version`)
- Task naming conventions consistent (describe what happens, not how)

### 4.2 Clarity
- Ansible code is self-documenting with clear task names
- Complex logic explained with inline comments
- Variable purposes documented in defaults/main.yml

### 4.3 Modularity
- Each tool has its own role with clear boundaries
- Roles can be included/excluded independently
- Minimal coupling between roles

### 4.4 Testability
- Each role can be tested independently
- Test playbooks validate installation and basic functionality
- Dry-run (--check) mode supports validation without changing system

---

## 5. Constraints and Limitations

### 5.1 System Requirements
- **Operating System:** Ubuntu 20.04 LTS or later (focal, jammy, noble)
- **Architecture:** x86_64 or ARM64 (aarch64)
- **Disk Space:** Minimum 20 GB free (recommended 50 GB for full tools and optional databases)
- **Internet Access:** Required for package downloads
- **RAM:** Minimum 2 GB (4+ GB recommended for Minikube)

### 5.2 Ansible Requirements
- **Ansible Version:** 2.9 or later (3.0+ recommended)
- **Python Version:** Python 3.6+ on control machine
- **Network:** Control machine can reach managed nodes (local or remote)

### 5.3 Tool Constraints
- Some tools (Minikube, Docker) require virtualization support; error handling provided
- Snap packages may not available on all systems; fallback to apt when possible
- Binary downloads dependent on network availability and external mirrors

### 5.4 Scope Limitations
- **Out of Scope:** Docker Engine (can be added as extension)
- **Out of Scope:** IDE installation beyond Sublime Text (PyCharm, IntelliJ, VS Code can be added as extensions)
- **Out of Scope:** Desktop environment customization (GNOME, KDE configs beyond tool configuration)
- **Out of Scope:** System-wide security hardening (firewall, SELinux)

---

## 6. Dependencies and External Systems

### 6.1 External Package Repositories
- Ubuntu official repositories (archive.ubuntu.com, security.ubuntu.com)
- Hashicorp repository for Terraform
- Kubernetes repository for kubectl
- Docker repository for container tools (if extended)

### 6.2 External Binary Sources
- HashiCorp releases (terraform, consul, etc.)
- Kubernetes release artifacts
- Minikube release artifacts

### 6.3 Third-Party Tools
- Ansible (control machine)
- Git (version control)
- GitHub Actions (CI/CD)

---

## 7. Success Criteria and Acceptance Tests

### 7.1 Installation Success
- [ ] Playbook runs without errors on fresh Ubuntu 20.04, 22.04, 24.04
- [ ] All required tools installed and executable
- [ ] Tool versions match configured defaults
- [ ] All environment variables set correctly
- [ ] Shell configuration applied (zsh with OhMyZsh)

### 7.2 Idempotency Success
- [ ] Second playbook run reports no changes (or only handlers)
- [ ] Repeated runs do not fail or produce errors
- [ ] No reinstalls occur on subsequent runs
- [ ] System state remains consistent

### 7.3 Customization Success
- [ ] Tool versions configurable via group_vars
- [ ] Optional databases installable/removable via flags
- [ ] Custom roles can be added without modifying core playbook
- [ ] Example playbooks demonstrate customization

### 7.4 Code Quality Success
- [ ] ansible-lint passes with zero errors
- [ ] yamllint passes with zero errors
- [ ] ansible-playbook --syntax-check passes
- [ ] Dry-run (--check) completes without errors
- [ ] All tests pass

### 7.5 Documentation Success
- [ ] README.md includes quick-start and usage
- [ ] SDD.md explains architecture and design
- [ ] git-spec.md documents development workflow
- [ ] Each role has README.md with variables and examples
- [ ] Troubleshooting guide addresses common issues

---

## 8. Release and Versioning

### 8.1 Version Numbering
- Semantic versioning: MAJOR.MINOR.PATCH
- v1.0.0: Initial release with core tools
- v1.x.x: Minor updates, new tools, bug fixes
- v2.0.0: Major breaking changes

### 8.2 Supported Versions
- Latest version: Active development
- Previous minor version: 6 months support
- Older versions: Community support only

---

## 9. Glossary and Abbreviations

| Term | Definition |
|------|-----------|
| IaC | Infrastructure as Code |
| SDD | Software Design Document |
| FR | Functional Requirement |
| NFR | Non-Functional Requirement |
| PDE | Personal Development Environment |
| LTS | Long Term Support |
| Idempotent | Can be applied multiple times with same result |
| Playbook | Ansible automation file containing tasks and roles |
| Role | Reusable Ansible component with tasks, handlers, vars |
| Inventory | Ansible file listing target systems |
| Handler | Ansible task triggered by a notify |
| Fact | System information gathered by Ansible |

---

## 10. Document Control

| Version | Date | Author | Changes |
|---------|------|--------|---------|
| 1.0.0 | 2026-05-09 | Copilot | Initial specification |
| 1.1.0 | 2026-05-11 | Claude  | Add git role (FR-2.1.3): install git + git-extras, global config |

---

**End of Specification**
