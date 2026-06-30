#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=utils.sh
source "${SCRIPT_DIR}/utils.sh"

logger_init

if command_exists zoxide; then
  ui_success "zoxide ready (initialized in .zshrc)"
else
  ui_warn "zoxide not found"
fi
