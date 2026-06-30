#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=utils.sh
source "${SCRIPT_DIR}/utils.sh"

logger_init

BTOP_DIR="${HOME}/.config/btop"
mkdir -p "${BTOP_DIR}/themes"

deploy_file "${ROOT_DIR}/configs/btop/btop.conf" "${BTOP_DIR}/btop.conf"
deploy_file "${ROOT_DIR}/configs/btop/btop-split.conf" "${BTOP_DIR}/btop-split.conf"
deploy_file "${ROOT_DIR}/configs/btop/themes/carbon.theme" "${BTOP_DIR}/themes/carbon.theme"

ui_success "btop configured (carbon theme + split layout)"
ui_dim "Dashboard uses btop-split.conf in the left Ghostty pane"
