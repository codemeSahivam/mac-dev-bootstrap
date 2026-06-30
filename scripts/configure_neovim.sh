#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=utils.sh
source "${SCRIPT_DIR}/utils.sh"

logger_init

if [[ "${INSTALL_NEOVIM:-true}" != "true" ]]; then
  ui_dim "Neovim skipped (disabled)"
  exit 0
fi

NVIM_DEST="${HOME}/.config/nvim"
NVIM_SRC="${ROOT_DIR}/configs/nvim"

mkdir -p "${NVIM_DEST}"

if [[ -f "${NVIM_SRC}/init.lua" ]]; then
  deploy_file "${NVIM_SRC}/init.lua" "${NVIM_DEST}/init.lua"
fi

ui_success "Neovim configured"
