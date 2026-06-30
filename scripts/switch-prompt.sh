#!/usr/bin/env bash
# Switch Starship prompt style
# Usage: ./scripts/switch-prompt.sh [classic|macos|arrow|dev] [theme]

set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
# shellcheck source=utils.sh
source "${ROOT}/scripts/utils.sh"

STYLES=(classic macos arrow dev)
PROMPT_STYLE="${1:-classic}"
THEME="${2:-catppuccin}"

if [[ ! " ${STYLES[*]} " =~ ${PROMPT_STYLE} ]]; then
  die "Unknown style: ${PROMPT_STYLE}. Use: ${STYLES[*]}"
fi

export PROMPT_STYLE THEME
bash "${ROOT}/scripts/configure_starship.sh"

ui_success "Prompt style: ${PROMPT_STYLE} (theme: ${THEME})"
ui_dim "Run: exec zsh"
