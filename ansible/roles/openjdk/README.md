# OpenJDK Role

Installs OpenJDK Java Development Kit.

## Variables

- `openjdk_version`: OpenJDK version (default: "17")

## Usage

```yaml
- role: openjdk
  vars:
    openjdk_version: "17"
```

## Idempotency

Role is fully idempotent. Running multiple times is safe.
