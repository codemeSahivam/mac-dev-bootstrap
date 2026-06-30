#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=utils.sh
source "${SCRIPT_DIR}/utils.sh"

logger_init

THEME="${THEME:-catppuccin}"
BASE="${ROOT_DIR}/configs/ghostty/config"
THEME_SNIPPET="${ROOT_DIR}/themes/${THEME}/ghostty"

DEST="${HOME}/.config/ghostty/config"
mkdir -p "${HOME}/.config/ghostty"

{
  cat "${BASE}"
  echo ""
  echo "# Theme: ${THEME}"
  if [[ -f "${THEME_SNIPPET}" ]]; then
    cat "${THEME_SNIPPET}"
  fi
} >"${DEST}.new"

if [[ -f "${DEST}" ]] && cmp -s "${DEST}.new" "${DEST}"; then
  rm "${DEST}.new"
  ui_dim "Ghostty config unchanged"
else
  [[ -f "${DEST}" ]] && backup_file "${DEST}" >/dev/null
  mv "${DEST}.new" "${DEST}"
  ui_success "Ghostty configured (${THEME})"
fi
