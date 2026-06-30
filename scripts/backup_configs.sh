#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=utils.sh
source "${SCRIPT_DIR}/utils.sh"

logger_init

TARGETS=(
  "${HOME}/.zshrc"
  "${HOME}/.gitconfig"
  "${HOME}/.tmux.conf"
  "${HOME}/.config/ghostty/config"
  "${HOME}/.config/starship.toml"
  "${HOME}/.config/fastfetch/config.jsonc"
  "${HOME}/.config/nvim"
)

ui_step "Backing up existing configuration"
mkdir -p "${BACKUP_ROOT}"

for target in "${TARGETS[@]}"; do
  if [[ -e "${target}" ]]; then
    backup_file "${target}"
  fi
done

ui_success "Backups complete (suffix: .backup.YYYYMMDDHHMMSS)"
