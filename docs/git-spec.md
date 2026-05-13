# Git Workflow Specification

**Version**: 1.0  
**Last Updated**: 2026-04-29

## 1. Branch Model

We follow a simplified Git Flow model:

### Main Branches

- **`main`**: Production-ready code. Merged PRs only. Protected branch (requires reviews).
- **`develop`**: Integration branch. Features and fixes merged here first.

### Supporting Branches

- **Feature branches**: `feature/<feature-name>` (base: `develop`)
- **Bugfix branches**: `bugfix/<bug-name>` (base: `develop`)
- **Hotfix branches**: `hotfix/<issue-name>` (base: `main`, merge to `develop` after)
- **Release branches**: `release/<version>` (base: `develop`, merge to `main` and `develop`)

### Branch Naming Rules

- Use lowercase
- Use hyphens for multi-word names
- Keep it short and descriptive
- Examples:
  - `feature/add-dockerfile`
  - `bugfix/fix-python-version-check`
  - `hotfix/security-patch`

## 2. Commit Message Convention

Follow [Conventional Commits](https://www.conventionalcommits.org/) v1.0.0:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Type

- **feat**: A new feature
- **fix**: A bug fix
- **refactor**: Code refactoring without feature/fix
- **docs**: Documentation-only changes
- **test**: Adding/updating tests
- **ci**: CI/CD configuration changes
- **chore**: Build system, dependencies, minor changes

### Scope

Optional, but recommended for clarity:
- `python`, `go`, `terraform`, `kubectl`, `mysql`, `mongodb`, etc.
- `playbook`, `inventory`, `role`
- `ci`, `docs`, `build`

### Description

- Imperative mood ("add" not "added" or "adds")
- Start with lowercase (unless it starts with code)
- No period at end
- Max 50 characters

### Body

- Optional, but include for non-trivial commits
- Explain **why**, not what (diffs show what)
- Wrap at 72 characters
- Use bullet points for multiple reasons

### Footer

- Optional
- Reference issues: `Closes #123` or `Fixes #456`
- Breaking changes: `BREAKING CHANGE: <description>`

### Examples

```
feat(python): add python3.11 support

- Updated ansible role to support Python 3.11
- Added version pinning to defaults/main.yml
- Tested on Ubuntu 22.04

Closes #42
```

```
fix(terraform): correct workspace initialization

Terraform workspace was not properly initialized before plan,
causing intermittent failures in CI. Added pre-plan validation task.

Fixes #89
```

```
docs: update git workflow in git-spec.md
```

```
ci(github-actions): add ubuntu 24.04 to test matrix
```

## 3. Tag and Versioning

We follow [Semantic Versioning](https://semver.org/):

```
<major>.<minor>.<patch>[-<pre-release>][+<build-metadata>]
```

### Version Rules

- **MAJOR**: Breaking changes to playbook/inventory (unlikely)
- **MINOR**: New roles, new features, tool version bumps
- **PATCH**: Bug fixes, minor updates, documentation

### Tag Format

```
v<major>.<minor>.<patch>
```

Examples:
- `v1.0.0` - Initial release
- `v1.1.0` - Added new role or tool
- `v1.1.1` - Bug fix
- `v1.0.0-rc1` - Release candidate

### Tagging Process

1. Update version in `VERSION` file (if present) or commit message
2. Create annotated tag: `git tag -a v1.1.0 -m "Release v1.1.0"`
3. Push tags: `git push origin --tags`
4. GitHub Actions auto-creates release on tag push

## 4. Pull Request Workflow

### PR Requirements

1. **Branching**: Create PR from feature branch to `develop` (or `main` for hotfixes)
2. **Naming**: Use descriptive title matching commit convention
3. **Description**: Fill out PR template below
4. **Checks**: All CI checks must pass (lint, syntax, dry-run)
5. **Reviews**: Require at least 1 approval before merge
6. **Conversations**: Resolve all comments before merging

### PR Template

```markdown
## Description

Briefly describe the changes and why they're needed.

## Related Issues

Closes #123
Relates to #456

## Type of Change

- [ ] Feature (new tool/role)
- [ ] Bugfix
- [ ] Refactoring
- [ ] Documentation
- [ ] Dependency update
- [ ] CI/CD change

## Checklist

- [ ] Commits follow conventional commit format
- [ ] `make lint` passes
- [ ] `make test` passes
- [ ] Changes tested locally (`make check`, `make apply`)
- [ ] Documentation updated (README, role README, SDD if needed)
- [ ] No secrets committed (API keys, passwords, SSH keys)
- [ ] Code is idempotent (safe to re-run)

## Testing

Describe how changes were tested:
- Dry-run: `make check`
- Full run: `make apply`
- Specific tag: `make apply TAGS="python"`
- Re-run verification: Changes are idempotent

## Screenshots/Logs (if applicable)

Attach dry-run output or relevant logs.
```

### PR Review Checklist (Reviewers)

- [ ] Commits follow Conventional Commits
- [ ] Description is clear and references issues
- [ ] Code is idempotent (no `shell`, proper `changed_when`)
- [ ] Playbook/roles follow Ansible best practices
- [ ] No hardcoded secrets or sensitive data
- [ ] Tests pass in CI
- [ ] Changes work in dry-run and full run
- [ ] Documentation is updated (README, role docs, comments if needed)

### Merging

- Squash commits for feature branches (clean history)
- Or keep commits if they tell a clear story
- Delete branch after merge
- Merge button only enabled after CI passes + approval

## 5. Continuous Integration

### GitHub Actions (ci.yml)

Runs on:
- Every push to `main` or `develop`
- Every PR to `main` or `develop`

Checks:
1. `ansible-lint` - Best practices
2. `yamllint` - YAML syntax
3. `ansible-playbook --syntax-check` - Playbook syntax
4. `ansible-playbook --check` - Dry-run simulation

**Failure**: Blocks PR merge. Fix linting errors and push new commit.

## 6. Releases

### Release Checklist

1. **Create release branch**: `git checkout -b release/v1.1.0`
2. **Update documentation**: Version numbers in README, SDD, etc.
3. **Create PR**: To `main` with type `release: v1.1.0`
4. **Merge to main**: After approval
5. **Tag release**: `git tag -a v1.1.0 -m "Release v1.1.0"`
6. **Push tag**: `git push origin --tags`
7. **Merge back to develop**: Ensure `develop` gets the tag info
8. **GitHub release**: Create release notes from PR description

## 7. CODEOWNERS

See `CODEOWNERS` file for maintainers by area. PRs automatically request reviews from code owners.

## 8. Troubleshooting

### Q: My branch is behind main, how do I update it?

```bash
git fetch origin
git rebase origin/main
# or merge if rebasing causes issues:
git merge origin/main
```

### Q: How do I undo a commit?

```bash
# Undo last commit (keep changes)
git reset --soft HEAD~1

# Undo last commit (discard changes)
git reset --hard HEAD~1
```

### Q: I committed to the wrong branch, what do I do?

```bash
# Save commits
git log --oneline (note the commit hashes)

# Switch to correct branch
git checkout feature/correct-branch

# Cherry-pick commits
git cherry-pick <hash1> <hash2>

# Go back to wrong branch and reset
git checkout wrong-branch
git reset --hard HEAD~2
```

### Q: CI is failing on lint, how do I fix it?

```bash
# See what's wrong
make lint

# Fix issues (usually formatting)
# Then re-test
make lint
```

## 9. Policy

- **Protected Branches**: `main`, `develop` require PR reviews
- **Commit History**: Preferably linear (rebasing encouraged)
- **Force Push**: Never on `main` or `develop`
- **Stale Branches**: Delete after merge
