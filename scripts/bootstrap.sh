#!/usr/bin/env bash
#
# Liongate workstation bootstrap.
#
# Ensures Ansible is available on a freshly installed Ubuntu LTS, then runs the
# provisioning playbook. Safe to re-run: it installs nothing that is already
# present, and the playbook itself is idempotent.
#
# Usage:
#   scripts/bootstrap.sh              # provision the full technical stack
#   scripts/bootstrap.sh --tags dev   # extra args are forwarded to ansible-playbook
#
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PLAYBOOK="site.yml"

log()  { printf '\033[1;34m[bootstrap]\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m[bootstrap]\033[0m %s\n' "$*" >&2; }
die()  { printf '\033[1;31m[bootstrap]\033[0m %s\n' "$*" >&2; exit 1; }

# Read a KEY=value field from /etc/os-release without sourcing the file.
os_release_field() {
  sed -n "s/^$1=//p" /etc/os-release 2>/dev/null | tr -d '"' | head -n1
}

check_os() {
  [[ -r /etc/os-release ]] || die "Cannot read /etc/os-release; unsupported OS."
  local id version
  id="$(os_release_field ID)"
  version="$(os_release_field VERSION_ID)"
  if [[ "${id}" == "ubuntu" ]]; then
    log "Detected Ubuntu ${version:-unknown}."
  else
    warn "This bootstrap targets Ubuntu LTS; detected '${id:-unknown}'. Continuing anyway (unsupported)."
  fi
}

ensure_ansible() {
  if command -v ansible-playbook >/dev/null 2>&1; then
    log "Ansible already present: $(ansible-playbook --version | head -n1)"
    return
  fi
  command -v apt-get >/dev/null 2>&1 || die "apt-get not found; install Ansible manually and re-run."
  log "Ansible not found; installing via apt..."
  sudo apt-get update -y
  sudo apt-get install -y ansible
  command -v ansible-playbook >/dev/null 2>&1 || die "Ansible installation failed."
  log "Installed: $(ansible-playbook --version | head -n1)"
}

main() {
  check_os
  ensure_ansible
  # Run from the repo root so ansible.cfg (and its inventory) is picked up.
  cd "${REPO_ROOT}" || die "Cannot enter ${REPO_ROOT}"
  log "Running playbook: ${PLAYBOOK} (inventory from ansible.cfg)"
  ansible-playbook "${PLAYBOOK}" "$@"
  log "Bootstrap complete."
}

main "$@"
