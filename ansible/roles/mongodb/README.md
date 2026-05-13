# MongoDB Role

Installs and configures MongoDB database server (optional).

## Variables

- `mongodb_version`: MongoDB version (default: "6.0")

## Usage

Enable MongoDB in inventory:

```yaml
enable_mongodb: true
```

Then run database playbook:

```bash
ansible-playbook ansible/playbooks/database.yml --tags mongodb
```

## Idempotency

Role is fully idempotent. Running multiple times is safe.

## Notes

- Installs MongoDB from official repository
- Starts and enables mongod service
- Supports Ubuntu focal, jammy, and noble
- Optional role (controlled by enable_mongodb variable)
