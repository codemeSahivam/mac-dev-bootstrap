#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=utils.sh
source "${SCRIPT_DIR}/utils.sh"

logger_init
ensure_brew_path

brew_install_cask font-jetbrains-mono-nerd-font || true
ui_success "JetBrains Mono Nerd Font ready"
ui_dim "Ghostty font: JetBrainsMono Nerd Font"
