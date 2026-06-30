#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=utils.sh
source "${SCRIPT_DIR}/utils.sh"

logger_init

deploy_file \
  "${ROOT_DIR}/configs/fastfetch/config.jsonc" \
  "${HOME}/.config/fastfetch/config.jsonc"

ui_success "Fastfetch configured"
