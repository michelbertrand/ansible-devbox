# Maven Role

Installs Apache Maven build tool for Java projects.

## Variables

- `maven_version`: Maven version (default: "present" = latest)

## Dependencies

Requires OpenJDK role (automatically included in site.yml)

## Usage

```yaml
- role: maven
```

## Idempotency

Role is fully idempotent. Running multiple times is safe.
