# IntelliJ IDEA Role

Installs IntelliJ IDEA by downloading the official tarball from JetBrains, extracting it
to `/opt`, and registering a CLI launcher (`idea`) and desktop entry.

Since IntelliJ IDEA 2025.3, JetBrains ships a single ("unified") binary for Community and
Ultimate: without a license, only the free Community feature set is active. This role
installs that unified binary, so no separate Community/Ultimate download exists.

## Variables

- `intellij_version`: Version to install (default: `2025.3`)
- `intellij_build`: Build number matching `intellij_version`, used to locate the extracted
  directory (default: `253.28294.334`)
- `intellij_install_root`: Base directory to install into (default: `/opt`)

## Usage

```yaml
- role: intellij
  vars:
    intellij_version: "2025.3"
```

## Bumping the Version

`intellij_version`, `intellij_build`, and the checksums in `vars/main.yml` must all be
updated together:

1. Find the new version/build at `https://data.services.jetbrains.com/products/releases?code=IIC&latest=true&type=release`
2. Update `intellij_version` and `intellij_build` in `defaults/main.yml`
3. Update `intellij_checksums.amd64` / `.arm64` in `vars/main.yml` from
   `https://download.jetbrains.com/idea/idea-<version>.tar.gz.sha256` and
   `https://download.jetbrains.com/idea/idea-<version>-aarch64.tar.gz.sha256`

## Idempotency

Role is fully idempotent. Running multiple times is safe:
- Download and extraction are skipped once `/opt/idea-IU-<build>` exists
- The `/opt/idea` symlink and CLI/desktop entries are refreshed on every run

## Testing

```bash
sudo ansible-playbook ansible/playbooks/site.yml \
  --inventory ansible/inventory/hosts.ini \
  --tags "intellij" \
  --check
```
