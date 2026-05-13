# Gradle Role

Installs Gradle build automation tool from official binaries.

## Variables

- `gradle_version`: Gradle version (default: "8.0")

## Dependencies

Requires OpenJDK role (automatically included in site.yml)

## Usage

```yaml
- role: gradle
  vars:
    gradle_version: "8.0"
```

## Idempotency

Role is fully idempotent:
- Skips download if Gradle version already installed
- Retries download up to 3 times if network error
- Safe to run multiple times

## Features

- Installed to /opt/gradle (with version subdirectory)
- Creates symlink /opt/gradle for easy access
- Sets PATH in ~/.bashrc and ~/.zshrc
- Includes unzip utility installation
- Retries on network failures

## Installation Details

- Checks for existing installation before download
- Downloads from https://services.gradle.org/distributions/
- Extracts to /opt/gradle-{version}
- Creates symlink for easy version switching
- Verifies installation with `gradle --version`

## Testing

```bash
gradle --version
gradle -v
```
