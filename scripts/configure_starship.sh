#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=utils.sh
source "${SCRIPT_DIR}/utils.sh"

logger_init

THEME="${THEME:-catppuccin}"
SRC="${ROOT_DIR}/configs/starship/starship.toml"
THEME_SRC="${ROOT_DIR}/themes/${THEME}/starship.toml"
DEST="${HOME}/.config/starship.toml"

mkdir -p "${HOME}/.config"

deploy_file "${ROOT_DIR}/configs/starship/starship.dev.toml" "${HOME}/.config/starship.dev.toml"

{
  cat "${SRC}"
  if [[ -f "${THEME_SRC}" ]]; then
    echo ""
    cat "${THEME_SRC}"
  fi
} >"${DEST}.new"

if [[ -f "${DEST}" ]] && cmp -s "${DEST}.new" "${DEST}"; then
  rm "${DEST}.new"
  ui_dim "Starship config unchanged"
else
  [[ -f "${DEST}" ]] && backup_file "${DEST}" >/dev/null
  mv "${DEST}.new" "${DEST}"
  ui_success "Starship configured (${THEME}, minimal)"
fi
