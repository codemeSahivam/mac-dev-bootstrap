#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=utils.sh
source "${SCRIPT_DIR}/utils.sh"

logger_init

if [[ "${INSTALL_TMUX:-true}" != "true" ]]; then
  ui_dim "tmux skipped (disabled)"
  exit 0
fi

deploy_file "${ROOT_DIR}/configs/tmux/.tmux.conf" "${HOME}/.tmux.conf"
ui_success "tmux configured"
