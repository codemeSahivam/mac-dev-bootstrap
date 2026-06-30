#!/usr/bin/env bash
# mac-dev-bootstrap — Uninstall / restore backups

set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/utils.sh
source "${ROOT}/scripts/utils.sh"

RESTORE=false
REMOVE_PACKAGES=false

usage() {
  cat <<'EOF'
Usage: ./uninstall.sh [OPTIONS]

Options:
  --restore           Restore most recent .backup.* files in $HOME
  --remove-packages   Uninstall Homebrew packages (destructive)
  -h, --help          Show help
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --restore)         RESTORE=true; shift ;;
    --remove-packages) REMOVE_PACKAGES=true; shift ;;
    -h|--help)         usage; exit 0 ;;
    *)                 die "Unknown option: $1" ;;
  esac
done

restore_backups() {
  ui_step "Restoring backups"
  local pattern='*.backup.*'
  local restored=0

  # Restore dotfiles in HOME
  while IFS= read -r backup; do
    local original="${backup%.backup.*}"
    if [[ -n "${original}" && "${original}" != "${backup}" ]]; then
      cp -R "${backup}" "${original}"
      ui_dim "Restored ${original}"
      ((restored++)) || true
    fi
  done < <(find "${HOME}" -maxdepth 4 -name "${pattern}" -type f 2>/dev/null | sort -r)

  # Also check .config paths
  while IFS= read -r backup; do
    local original="${backup%.backup.*}"
    if [[ -n "${original}" && -f "${backup}" ]]; then
      mkdir -p "$(dirname "${original}")"
      cp "${backup}" "${original}"
      ui_dim "Restored ${original}"
      ((restored++)) || true
    fi
  done < <(find "${HOME}/.config" -name "${pattern}" -type f 2>/dev/null | sort -r)

  if (( restored > 0 )); then
    ui_success "Restored ${restored} file(s)"
  else
    ui_warn "No .backup.* files found under ${HOME}"
  fi
}

remove_symlinks() {
  local modular="${HOME}/.config/mac-dev-bootstrap"
  [[ -d "${modular}" ]] && rm -rf "${modular}"
  ui_dim "Removed ${modular}"
}

remove_packages() {
  ensure_brew_path
  ui_warn "Removing formulae..."
  brew uninstall starship fastfetch eza bat fzf fd ripgrep jq yq tree btop \
    git-delta lazygit zoxide tmux neovim wget curl htop kubectl helm kubectx kubens 2>/dev/null || true
  brew uninstall --cask ghostty font-jetbrains-mono-nerd-font 2>/dev/null || true
}

main() {
  logger_init
  ui_step "mac-dev-bootstrap uninstall"

  if [[ "${RESTORE}" == "true" ]]; then
    restore_backups
  fi

  remove_symlinks

  if [[ "${REMOVE_PACKAGES}" == "true" ]]; then
    remove_packages
  fi

  [[ -f "${STATE_DIR}/installed" ]] && rm -f "${STATE_DIR}/installed"
  ui_success "Uninstall complete"
  ui_dim "Backups remain as *.backup.* alongside originals' paths"
}

main "$@"
