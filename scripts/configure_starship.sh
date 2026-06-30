#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=utils.sh
source "${SCRIPT_DIR}/utils.sh"

logger_init

THEME="${THEME:-catppuccin}"
PROMPT_STYLE="${PROMPT_STYLE:-classic}"
PROMPT_SRC="${ROOT_DIR}/configs/starship/prompts/${PROMPT_STYLE}.toml"
THEME_SRC="${ROOT_DIR}/themes/${THEME}/starship.toml"
DEST="${HOME}/.config/starship.toml"

[[ -f "${PROMPT_SRC}" ]] || die "Prompt style not found: ${PROMPT_STYLE}"

mkdir -p "${HOME}/.config"

deploy_file "${ROOT_DIR}/configs/starship/prompts/dev.toml" "${HOME}/.config/starship.dev.toml"

{
  cat "${PROMPT_SRC}"
  if [[ -f "${THEME_SRC}" ]]; then
    echo ""
    cat "${THEME_SRC}"
  fi
} >"${DEST}.new"

if [[ -f "${DEST}" ]] && cmp -s "${DEST}.new" "${DEST}"; then
  rm "${DEST}.new"
  ui_dim "Starship config unchanged"
else
  [[ -f "${DEST}" ]] && backup_file "${DEST}" >/dev/null
  mv "${DEST}.new" "${DEST}"
  ui_success "Starship prompt: ${PROMPT_STYLE} (theme: ${THEME})"
fi

# Save preference
mkdir -p "${HOME}/.config/mac-dev-bootstrap"
echo "PROMPT_STYLE=${PROMPT_STYLE}" >"${HOME}/.config/mac-dev-bootstrap/prompt.env"
echo "THEME=${THEME}" >>"${HOME}/.config/mac-dev-bootstrap/prompt.env"
