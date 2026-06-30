#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=utils.sh
source "${SCRIPT_DIR}/utils.sh"

logger_init

ZSH_DIR="${ROOT_DIR}/configs/zsh"
MODULAR="${HOME}/.config/mac-dev-bootstrap/zsh"
mkdir -p "${MODULAR}"

# Deploy modular zsh files
for f in aliases.zsh functions.zsh exports.zsh; do
  deploy_file "${ZSH_DIR}/${f}" "${MODULAR}/${f}"
done

# Build .zshrc from template with feature flags
TEMPLATE="${ZSH_DIR}/.zshrc"
DEST="${HOME}/.zshrc"

{
  cat "${TEMPLATE}"
  echo ""
  echo "# ── Runtime flags (set by installer) ──"
  echo "export MDB_USE_OH_MY_ZSH=${USE_OH_MY_ZSH:-false}"
  echo "export MDB_FASTFETCH_ON_START=${FASTFETCH_ON_START:-true}"
  echo "export MDB_ZSH_PLUGINS='${ZSH_PLUGINS:-}'"
} >"${DEST}.new"

if [[ -f "${DEST}" ]] && cmp -s "${DEST}.new" "${DEST}"; then
  rm "${DEST}.new"
  ui_dim ".zshrc unchanged"
else
  [[ -f "${DEST}" ]] && backup_file "${DEST}" >/dev/null
  mv "${DEST}.new" "${DEST}"
fi

# Zsh plugins (Oh My Zsh + plain zsh)
ZSH_CUSTOM_OMZ="${HOME}/.oh-my-zsh/custom"
ZSH_CUSTOM_PLAIN="${HOME}/.config/mac-dev-bootstrap/omz-plugins"
mkdir -p "${ZSH_CUSTOM_OMZ}/plugins" "${ZSH_CUSTOM_PLAIN}"

declare -a PLUGIN_REPOS=(
  "zsh-autosuggestions|https://github.com/zsh-users/zsh-autosuggestions"
  "zsh-syntax-highlighting|https://github.com/zsh-users/zsh-syntax-highlighting"
)

install_plugin() {
  local name="$1" repo="$2" dest="$3"
  if [[ ! -d "${dest}" ]]; then
    git clone --depth=1 "${repo}" "${dest}" >>"${LOG_FILE}" 2>&1 || ui_warn "Plugin ${name} failed"
  fi
}

for entry in "${PLUGIN_REPOS[@]}"; do
  name="${entry%%|*}"
  repo="${entry##*|}"
  install_plugin "${name}" "${repo}" "${ZSH_CUSTOM_PLAIN}/${name}"
  if [[ "${USE_OH_MY_ZSH:-false}" == "true" ]]; then
    install_plugin "${name}" "${repo}" "${ZSH_CUSTOM_OMZ}/plugins/${name}"
  fi
done

# Oh My Zsh framework
if [[ "${USE_OH_MY_ZSH:-false}" == "true" ]]; then
  if [[ ! -d "${HOME}/.oh-my-zsh" ]]; then
    ui_info "Installing Oh My Zsh..."
    RUNZSH=no CHSH=no sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended >>"${LOG_FILE}" 2>&1 || ui_warn "Oh My Zsh install issue — check log"
  else
    ui_dim "Oh My Zsh already installed"
  fi
fi

# Default shell
if [[ "${SHELL:-}" != *zsh* ]] && command_exists zsh; then
  ui_info "Setting default shell to zsh..."
  chsh -s "$(command -v zsh)" >>"${LOG_FILE}" 2>&1 || ui_warn "Run manually: chsh -s $(command -v zsh)"
fi

ui_success "Zsh configured"
