# LIONGATE Env

Official company development environment repository. Contains workstation provisioning, developer tooling, VS Code settings, shell configurations, and onboarding automation.

## Features

- Ubuntu LTS Standardization
- Ansible-based Provisioning
- Docker & Docker Compose
- Node.js via NVM
- Python via pyenv
- Java via SDKMAN
- AWS CLI
- kubectl & Helm
- Terraform
- VS Code Standardization
- Git & SSH Configuration
- Automated Developer Onboarding

## Quick Start

On a freshly installed Ubuntu LTS:

```bash
git clone git@github.com:liongate-sarl/liongate-env.git
cd liongate-env
make bootstrap
```

`make bootstrap` installs Ansible if needed, then provisions the full technical stack. Run `make help` to see all available targets.
