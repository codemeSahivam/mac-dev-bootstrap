#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=utils.sh
source "${SCRIPT_DIR}/utils.sh"

logger_init

deploy_file "${ROOT_DIR}/configs/git/.gitconfig" "${HOME}/.gitconfig"

if [[ -n "${GIT_NAME:-}" ]]; then
  git config --global user.name "${GIT_NAME}"
fi
if [[ -n "${GIT_EMAIL:-}" ]]; then
  git config --global user.email "${GIT_EMAIL}"
fi

ui_success "Git configured (delta pager, aliases)"
