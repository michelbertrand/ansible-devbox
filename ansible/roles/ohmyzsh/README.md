# Oh My Zsh Role

Installs and configures Oh My Zsh shell framework for the current non-root user.

## Variables

- `ohmyzsh_theme`: Theme to use (default: "robbyrussell")
- `ohmyzsh_plugins`: List of plugins to enable (default: git, docker, kubectl)

## Usage

```yaml
- role: ohmyzsh
  vars:
    ohmyzsh_theme: "robbyrussell"
    ohmyzsh_plugins:
      - git
      - docker
      - kubectl
      - conda
```

## Idempotency

Role is fully idempotent. Running multiple times is safe:
- Detects existing Oh My Zsh installation
- Skips reinstall if already configured
- Safe to re-run for configuration updates

## User Detection

When running with `become: true` (sudo):
- Detects the original non-root user via `$SUDO_USER` environment variable
- Configures Oh My Zsh for that user, not for root
- Configures zsh as the default shell for the actual user

## Notes

- Installs zsh package if not present
- Sets zsh as default shell for the user
- Configures theme and plugins in .zshrc
- Creates .zshrc if needed (idempotent)
- Includes retry logic (3 retries) for downloading installer

