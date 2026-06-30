#!/usr/bin/env bash
# Ghostty startup hook — builds dashboard layout via AppleScript (macOS only)
set -euo pipefail

SCRIPT="${HOME}/.config/mac-dev-bootstrap/ghostty/dashboard.applescript"

if [[ "$(uname -s)" != "Darwin" ]]; then
  exec "${SHELL:-/bin/zsh}" -l
fi

if [[ ! -f "${SCRIPT}" ]]; then
  exec "${SHELL:-/bin/zsh}" -l
fi

osascript "${SCRIPT}" || exec "${SHELL:-/bin/zsh}" -l
exit 0
