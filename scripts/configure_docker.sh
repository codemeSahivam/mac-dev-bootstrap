#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=utils.sh
source "${SCRIPT_DIR}/utils.sh"

logger_init

if command_exists docker; then
  if docker info &>/dev/null; then
    ui_success "Docker is running"
  else
    ui_warn "Docker installed but daemon not running — start Docker Desktop"
  fi
else
  ui_dim "Docker CLI not found — install Docker Desktop if needed"
fi

ui_success "Docker completion enabled via .zshrc"
