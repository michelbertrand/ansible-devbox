# Node.js Role

Installs Node.js and npm from the official NodeSource apt repository. Exists primarily
as a dependency for tools distributed via npm (e.g. [claude_code](../claude_code)), but
can be used standalone.

## Variables

- `nodejs_version`: Node.js major version / NodeSource release channel (default: `22`)

## Usage

```yaml
- role: nodejs
  vars:
    nodejs_version: "22"
```

## Bumping the Version

1. Pick a supported Node.js major release line from `https://github.com/nodesource/distributions`
2. Update `nodejs_version` in `defaults/main.yml`

The NodeSource GPG key and its fingerprint (`vars/main.yml`) are stable across Node.js
versions and should only need updating if NodeSource rotates their signing key — see
`https://github.com/nodesource/distributions/wiki/Repository-Manual-Installation`.

## Idempotency

Role is fully idempotent. Running multiple times is safe: the GPG key is only
downloaded/verified/dearmored when missing, and `apt` only reports changes when the
package state actually changes.

## Check Mode

`apt_repository` only simulates adding the NodeSource repository under `--check`, so the
apt cache never actually contains the `nodejs` package on a dry run. The install and
verification tasks are skipped when `ansible_check_mode` is true to avoid a real (not
simulated) "package not found" failure.

## Testing

```bash
sudo ansible-playbook ansible/playbooks/site.yml \
  --inventory ansible/inventory/hosts.ini \
  --tags "nodejs" \
  --check
```
