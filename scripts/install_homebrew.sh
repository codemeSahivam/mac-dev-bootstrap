#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=utils.sh
source "${SCRIPT_DIR}/utils.sh"

logger_init

if command_exists brew; then
  ensure_brew_path
  ui_success "Homebrew already installed: $(command -v brew)"
  exit 0
fi

ui_info "Installing Homebrew..."
if is_apple_silicon; then
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >>"${LOG_FILE}" 2>&1
else
  NONINTERACTIVE=1 /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)" >>"${LOG_FILE}" 2>&1
fi

ensure_brew_path
command_exists brew || die "Homebrew installation failed. See ${LOG_FILE}"
ui_success "Homebrew installed at $(brew --prefix)"
