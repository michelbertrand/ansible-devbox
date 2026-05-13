# Sublime Text Role

Installs and configures Sublime Text editor via official Sublime HQ repository.

## Variables

- `sublime_text_version`: Version to install (default: "present" = latest)
- `sublime_text_packages`: Additional packages (default: [])

## Usage

```yaml
- role: sublime_text
  vars:
    sublime_text_version: present
```

## Repository Setup

Uses modern, secure repository configuration compatible with Ubuntu 20.04+:
- Downloads official Sublime Text GPG key to `/etc/apt/keyrings/sublime-text.gpg`
- Adds signed repository entry using `signed-by` parameter
- No deprecated `apt-key` command (removed in Ubuntu 22.04+)

## Idempotency

Role is fully idempotent. Running multiple times is safe:
- GPG key download is idempotent (overwrites if changed)
- Repository addition checks for existing state
- Package install only changes if needed

## Testing

```bash
sudo ansible-playbook ansible/playbooks/site.yml \
  --inventory ansible/inventory/hosts.ini \
  --tags "sublime_text" \
  --check
```

## Troubleshooting

**Issue: "Failed to find required executable 'apt-key'"**
- This is the old module error. Ensure role is updated to use `get_url` and `signed-by` parameter
- This fix works on Ubuntu 20.04, 22.04, and 24.04

**Issue: Repository verification failed**
- Network issue with downloading GPG key
- Run again - has 3 retries with 5-second delays built-in
- Check internet connectivity
