#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=utils.sh
source "${SCRIPT_DIR}/utils.sh"

logger_init
ensure_brew_path

if command_exists fzf; then
  local_prefix="$(brew --prefix)"
  if [[ -x "${local_prefix}/opt/fzf/install" ]]; then
    "${local_prefix}/opt/fzf/install" --key-bindings --completion --no-update-rc >>"${LOG_FILE}" 2>&1 || true
  fi
  ui_success "fzf key bindings installed"
else
  ui_warn "fzf not found"
fi
