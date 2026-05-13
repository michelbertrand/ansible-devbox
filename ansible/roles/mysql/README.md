# MySQL Role

Installs and configures MySQL database server (optional).

## Variables

- `mysql_root_password`: Root password (default: "changeme")
- `mysql_version`: MySQL version info (default: "8.0")

## Usage

Enable MySQL in inventory:

```yaml
enable_mysql: true
```

Then run database playbook:

```bash
ansible-playbook ansible/playbooks/database.yml --tags mysql
```

## Idempotency

Role is fully idempotent. Running multiple times is safe.

## Notes

- Starts and enables MySQL service
- Sets root password
- Creates .my.cnf for passwordless CLI access
- Optional role (controlled by enable_mysql variable)
