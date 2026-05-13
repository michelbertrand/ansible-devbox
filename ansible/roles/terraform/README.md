# Terraform Role

Installs HashiCorp Terraform infrastructure-as-code tool.

## Variables

- `terraform_version`: Terraform version (default: "1.5.0")

## Usage

```yaml
- role: terraform
  vars:
    terraform_version: "1.5.0"
```

## Idempotency

Role is fully idempotent. Running multiple times is safe.

## Notes

- Installed to /usr/local/bin/terraform
- Architecture auto-detected (amd64, arm64)
- Requires unzip utility
