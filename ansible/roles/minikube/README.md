# Minikube Role

Installs Minikube local Kubernetes cluster.

## Variables

- `minikube_version`: Minikube version (default: "latest")

## Usage

```yaml
- role: minikube
  vars:
    minikube_version: "latest"
```

## Idempotency

Role is fully idempotent. Running multiple times is safe.

## Notes

- Installs Docker as prerequisite
- Adds user to docker group for rootless operation
- Architecture auto-detected (amd64, arm64)
- Requires restart or group membership re-login for docker group changes
