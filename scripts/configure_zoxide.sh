#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=utils.sh
source "${SCRIPT_DIR}/utils.sh"

logger_init

if command_exists zoxide; then
  ui_success "zoxide ready (cd uses smart directory jumping)"
else
  ui_warn "zoxide not found — run install_packages.sh or: brew install zoxide"
fi
