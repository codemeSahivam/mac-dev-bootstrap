#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=utils.sh
source "${SCRIPT_DIR}/utils.sh"

logger_init

THEME="${THEME:-catppuccin}"
GHOSTTY_DASHBOARD="${GHOSTTY_DASHBOARD:-true}"
GHOSTTY_BACKGROUND="${GHOSTTY_BACKGROUND:-true}"
BASE="${ROOT_DIR}/configs/ghostty/config"
THEME_SNIPPET="${ROOT_DIR}/themes/${THEME}/ghostty"
MDB_GHOSTTY="${HOME}/.config/mac-dev-bootstrap/ghostty"
DEST="${HOME}/.config/ghostty/config"

mkdir -p "${HOME}/.config/ghostty" "${HOME}/.config/ghostty/backgrounds" "${MDB_GHOSTTY}" "${HOME}/.config/mac-dev-bootstrap/bin"

# Deploy wallpaper
BG_SRC="${ROOT_DIR}/assets/backgrounds/terminal.jpg"
BG_DEST="${HOME}/.config/ghostty/backgrounds/terminal.jpg"
if [[ "${GHOSTTY_BACKGROUND}" == "true" && -f "${BG_SRC}" ]]; then
  cp "${BG_SRC}" "${BG_DEST}"
  ui_dim "Wallpaper: ${BG_DEST}"
fi

ensure_brew_path
BTOP_BIN="$(command -v btop 2>/dev/null || echo "$(brew --prefix 2>/dev/null)/bin/btop")"
ZSH_BIN="$(command -v zsh)"

{
  cat "${BASE}"

  # window-save-state conflicts with scripted startup layout
  if [[ "${GHOSTTY_DASHBOARD}" == "true" && "$(uname -s)" == "Darwin" ]]; then
    echo "window-save-state = never"
    echo "maximize = true"
    echo "window-width = 240"
    echo "window-height = 55"
  else
    echo "window-save-state = always"
  fi

  echo ""
  echo "# Theme: ${THEME}"
  if [[ -f "${THEME_SNIPPET}" ]]; then
    cat "${THEME_SNIPPET}"
  fi

  if [[ "${GHOSTTY_BACKGROUND}" == "true" && -f "${BG_DEST}" ]]; then
    echo ""
    echo "# Terminal wallpaper"
    sed "s|{{BACKGROUND_IMAGE}}|${BG_DEST}|g" "${ROOT_DIR}/configs/ghostty/background"
  fi

  if [[ "${GHOSTTY_DASHBOARD}" == "true" && "$(uname -s)" == "Darwin" ]]; then
    if [[ -x "${BTOP_BIN}" ]]; then
      sed \
        -e "s|{{BTOP}}|${BTOP_BIN}|g" \
        -e "s|{{ZSH}}|${ZSH_BIN}|g" \
        "${ROOT_DIR}/configs/ghostty/dashboard.applescript" \
        >"${MDB_GHOSTTY}/dashboard.applescript"

      cp "${ROOT_DIR}/configs/ghostty/ghostty-dashboard-init.sh" \
        "${HOME}/.config/mac-dev-bootstrap/bin/ghostty-dashboard-init.sh"
      chmod +x "${HOME}/.config/mac-dev-bootstrap/bin/ghostty-dashboard-init.sh"

      echo ""
      echo "# Auto dashboard: btop (left) + fastfetch/zsh (right) on startup"
      echo "initial-command = ${HOME}/.config/mac-dev-bootstrap/bin/ghostty-dashboard-init.sh"
    else
      ui_warn "btop not found — skipping Ghostty dashboard startup"
    fi
  fi
} >"${DEST}.new"

if [[ -f "${DEST}" ]] && cmp -s "${DEST}.new" "${DEST}"; then
  rm "${DEST}.new"
  ui_dim "Ghostty config unchanged"
else
  [[ -f "${DEST}" ]] && backup_file "${DEST}" >/dev/null
  mv "${DEST}.new" "${DEST}"
  if [[ "${GHOSTTY_DASHBOARD}" == "true" ]]; then
    ui_success "Ghostty configured (${THEME}) + startup dashboard"
    ui_dim "First launch: allow Automation for Ghostty in System Settings"
  else
    ui_success "Ghostty configured (${THEME})"
  fi
fi
