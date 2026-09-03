# Insomnia Role

Installs Insomnia Essentials — Kong's free-tier API client (REST, GraphQL, gRPC,
WebSockets) — by downloading the official `.deb` package from the Kong/insomnia GitHub
releases and installing it with `apt`.

"Essentials" is the free plan built into the Insomnia app itself, not a separate
download: this role installs the standard Insomnia application, which runs on the
Essentials plan until a license is added.

## Variables

- `insomnia_version`: Version to install (default: `13.2.0`)

## Usage

```yaml
- role: insomnia
  vars:
    insomnia_version: "13.2.0"
```

## Bumping the Version

`insomnia_version` and the checksum in `vars/main.yml` must be updated together:

1. Find the new version at `https://github.com/Kong/insomnia/releases` (tag `core@<version>`)
2. Update `insomnia_version` in `defaults/main.yml`
3. Update `insomnia_checksum` in `vars/main.yml` with the sha256 digest of
   `Insomnia.Core-<version>.deb`, taken from the `subject` entries in that release's
   `insomnia-provenance.intoto.jsonl` attestation (GitHub does not publish a plain
   `.sha256` file for this asset)

## Idempotency

Role is fully idempotent. Running multiple times is safe: download and install are
skipped once the installed `insomnia` apt package already matches `insomnia_version`.

## Constraints

Kong only publishes official Insomnia Linux packages for x86_64; the role fails
explicitly on other architectures (e.g. ARM64).

## Testing

```bash
sudo ansible-playbook ansible/playbooks/site.yml \
  --inventory ansible/inventory/hosts.ini \
  --tags "insomnia" \
  --check
```
