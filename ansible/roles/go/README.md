# Go Role

Installs Go programming language from official binaries with checksum verification.

## Variables

- `go_version`: Go version to install (default: "1.21.0")
- `go_checksum`: SHA256 checksum for binary verification (format: `sha256:hash`)

## Usage

```yaml
- role: go
  vars:
    go_version: "1.21.0"
```

## Idempotency

Role is fully idempotent:
- Skips download if Go already installed
- Verifies binary with SHA256 checksum
- Retries download up to 3 times if network error
- Safe to run multiple times

## Features

- Sets GOPATH and PATH environment variables in ~/.bashrc and ~/.zshrc
- Architecture auto-detected (amd64, arm64)
- Creates symbolic links for go and gofmt in /usr/local/bin
- Includes checksum verification for security
- Robust error handling with retries

## Checksum Format

Checksums must be in format: `sha256:<hash>`
Example: `sha256:5901aa7db8d758af0f3c4a37b126e01f18f10e3f2e0e27ec1a7b5d5ea286c4e8`

Find latest checksums at: https://go.dev/dl/

## Testing

```bash
go version
go env GOPATH
```
