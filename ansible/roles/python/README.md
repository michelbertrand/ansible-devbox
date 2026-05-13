# Python Role

Installs Python 3 and development tools including pip and virtual environments.

## Variables

- `python_version`: Python version (default: "3.10") - informational only, installs latest available from apt
- `python_pip_packages`: List of pip packages to install (default: setuptools, wheel, virtualenv)

## Usage

```yaml
- role: python
  vars:
    python_pip_packages:
      - setuptools
      - wheel
      - virtualenv
      - jupyter
      - requests
      - numpy
```

## What Gets Installed

- `python3` - Python interpreter
- `python3-pip` - Package manager
- `python3-venv` - Virtual environment tools
- `python3-dev` - Development headers
- `build-essential` - Compiler and build tools
- Additional packages from `python_pip_packages` list

## Idempotency

Role is fully idempotent. Running multiple times is safe:
- Packages installed only if not already present
- Uses `pip3 install --upgrade` to install/update packages
- Detects successful installations from output messages

## Execution

- Installs system packages via apt
- Installs pip packages directly using `pip3 install` shell command
- Automatically upgrades packages to latest versions if already installed

## Testing

```bash
python3 --version
pip3 --version
virtualenv --version
python3 -c "import setuptools; print(setuptools.__version__)"
```
