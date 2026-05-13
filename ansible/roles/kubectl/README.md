# kubectl Role

Installs kubectl Kubernetes command-line tool.

## Variables

- `kubectl_version`: kubectl version (default: "latest")

## Usage

```yaml
- role: kubectl
  vars:
    kubectl_version: "latest"
```

## Idempotency

Role is fully idempotent. Running multiple times is safe.

## Notes

- Installed to /usr/local/bin/kubectl
- Architecture auto-detected (amd64, arm64)
- Requires network access to fetch stable version
