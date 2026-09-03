# Claude Code Role

Installs the [Claude Code](https://github.com/anthropics/claude-code) CLI
(`@anthropic-ai/claude-code`) globally via npm. Depends on the [nodejs](../nodejs) role
(declared in `meta/main.yml`), which is installed automatically first.

## Variables

- `claude_code_version`: npm package version to install (default: `2.1.259`)

## Usage

```yaml
- role: claude_code
  vars:
    claude_code_version: "2.1.259"
```

## Bumping the Version

1. Check the latest published version: `npm view @anthropic-ai/claude-code version`
2. Update `claude_code_version` in `defaults/main.yml`
3. Confirm the required Node.js major version (`npm view @anthropic-ai/claude-code engines`)
   is still satisfied by `nodejs_version` in the [nodejs role](../nodejs)

## Idempotency

Role is fully idempotent: `community.general.npm` only reinstalls the package when the
installed global version differs from `claude_code_version`.

## Check Mode

Installation and verification are skipped when `ansible_check_mode` is true, since they
depend on the `nodejs` role, which itself does not install a real `node`/`npm` binary
under `--check` (see the [nodejs role README](../nodejs/README.md#check-mode)).

## Testing

```bash
sudo ansible-playbook ansible/playbooks/site.yml \
  --inventory ansible/inventory/hosts.ini \
  --tags "claude_code" \
  --check
```
