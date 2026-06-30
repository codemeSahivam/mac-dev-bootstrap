#!/usr/bin/env bash
# mac-dev-bootstrap — macOS Developer Environment Installer
# Usage: ./install.sh [--non-interactive] [--theme NAME]

set -Eeuo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=scripts/utils.sh
source "${ROOT}/scripts/utils.sh"

NON_INTERACTIVE=false

usage() {
  cat <<'EOF'
mac-dev-bootstrap — Install a professional macOS dev environment

Usage:
  ./install.sh [OPTIONS]

Options:
  --non-interactive   Use defaults (Oh My Zsh, catppuccin, all optional components)
  --theme NAME        catppuccin | kanagawa | gruvbox | dracula
  --plain-zsh         Skip Oh My Zsh
  --no-fastfetch      Disable fastfetch on shell startup
  --no-tmux           Skip tmux configuration
  --no-neovim         Skip neovim configuration
  --no-ghostty        Skip Ghostty cask
  --no-dashboard      Disable Ghostty auto split (btop + fastfetch)
  --prompt-style NAME classic | macos | arrow | dev
  -h, --help          Show help

Examples:
  ./install.sh
  ./install.sh --theme gruvbox --plain-zsh
  ./install.sh --non-interactive
EOF
}

# Defaults
THEME="catppuccin"
USE_OH_MY_ZSH="true"
FASTFETCH_ON_START="true"
INSTALL_TMUX="true"
INSTALL_NEOVIM="true"
INSTALL_GHOSTTY="true"
GHOSTTY_DASHBOARD="true"
PROMPT_STYLE="classic"
GIT_NAME=""
GIT_EMAIL=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --non-interactive) NON_INTERACTIVE=true; shift ;;
    --theme)           THEME="$2"; shift 2 ;;
    --plain-zsh)       USE_OH_MY_ZSH="false"; shift ;;
    --no-fastfetch)    FASTFETCH_ON_START="false"; shift ;;
    --no-tmux)         INSTALL_TMUX="false"; shift ;;
    --no-neovim)       INSTALL_NEOVIM="false"; shift ;;
    --no-ghostty)      INSTALL_GHOSTTY="false"; shift ;;
    --no-dashboard)    GHOSTTY_DASHBOARD="false"; shift ;;
    --prompt-style)    PROMPT_STYLE="$2"; shift 2 ;;
    -h|--help)         usage; exit 0 ;;
    *)                 die "Unknown option: $1" ;;
  esac
done

export THEME USE_OH_MY_ZSH FASTFETCH_ON_START INSTALL_TMUX INSTALL_NEOVIM INSTALL_GHOSTTY GHOSTTY_DASHBOARD PROMPT_STYLE

ZSH_PLUGINS="git docker docker-compose kubectl helm terraform aws golang python history sudo command-not-found fzf zsh-autosuggestions zsh-syntax-highlighting"
export ZSH_PLUGINS

run_script() {
  local script="$1"
  bash "${ROOT}/scripts/${script}"
}

interactive_setup() {
  echo -e "${C_BOLD}mac-dev-bootstrap${C_RESET} — Interactive Setup"
  echo

  prompt_choice "Shell framework:" "Plain ZSH" "Oh My Zsh"
  if [[ "${REPLY}" == "Plain ZSH" ]]; then
    USE_OH_MY_ZSH="false"
  else
    USE_OH_MY_ZSH="true"
  fi

  prompt_choice "Terminal theme:" "Catppuccin Mocha" "Kanagawa" "Gruvbox" "Dracula"
  case "${REPLY}" in
    "Catppuccin Mocha") THEME="catppuccin" ;;
    Kanagawa)           THEME="kanagawa" ;;
    Gruvbox)            THEME="gruvbox" ;;
    Dracula)            THEME="dracula" ;;
  esac

  prompt_choice "Optional components (select defaults with 1):" \
    "All (tmux, neovim, fastfetch, ghostty)" \
    "Minimal (no tmux/neovim)"
  if [[ "${REPLY}" == "Minimal (no tmux/neovim)" ]]; then
    INSTALL_TMUX="false"
    INSTALL_NEOVIM="false"
  fi

  prompt_choice "Fastfetch on terminal startup?" "Yes" "No"
  [[ "${REPLY}" == "No" ]] && FASTFETCH_ON_START="false"

  if [[ -z "${GIT_NAME}" ]]; then
    GIT_NAME="$(git config --global user.name 2>/dev/null || true)"
    read -r -p "Git user.name [${GIT_NAME}]: " _gn
    GIT_NAME="${_gn:-${GIT_NAME}}"
  fi
  if [[ -z "${GIT_EMAIL}" ]]; then
    GIT_EMAIL="$(git config --global user.email 2>/dev/null || true)"
    read -r -p "Git user.email [${GIT_EMAIL}]: " _ge
    GIT_EMAIL="${_ge:-${GIT_EMAIL}}"
  fi

  prompt_choice "Prompt style:" "Classic (user@host ~ %)" "macOS (colored)" "Arrow (❯)" "Dev (git/k8s/docker)"
  case "${REPLY}" in
    "Classic (user@host ~ %)") PROMPT_STYLE="classic" ;;
    "macOS (colored)")         PROMPT_STYLE="macos" ;;
    "Arrow (❯)")               PROMPT_STYLE="arrow" ;;
    "Dev (git/k8s/docker)")    PROMPT_STYLE="dev" ;;
  esac

  export THEME USE_OH_MY_ZSH FASTFETCH_ON_START INSTALL_TMUX INSTALL_NEOVIM INSTALL_GHOSTTY GHOSTTY_DASHBOARD PROMPT_STYLE GIT_NAME GIT_EMAIL
}

print_summary() {
  ui_step "Installation Summary"
  ui_dim "Theme:          ${THEME}"
  ui_dim "Oh My Zsh:      ${USE_OH_MY_ZSH}"
  ui_dim "Fastfetch:      ${FASTFETCH_ON_START}"
  ui_dim "tmux:           ${INSTALL_TMUX}"
  ui_dim "Neovim:         ${INSTALL_NEOVIM}"
  ui_dim "Ghostty:        ${INSTALL_GHOSTTY}"
  ui_dim "Dashboard:      ${GHOSTTY_DASHBOARD}"
  ui_dim "Prompt:         ${PROMPT_STYLE}"
  ui_dim "Architecture:   $(detect_arch)"
  ui_dim "Log file:       ${LOG_FILE}"
  echo
  ui_success "Done! Restart your terminal or run: exec zsh"
  ui_dim "Edit configs in: ${ROOT}/configs/"
  ui_dim "Uninstall/restore: ./uninstall.sh --restore"
}

main() {
  logger_init
  check_macos

  echo -e "${C_MAGENTA}${C_BOLD}"
  cat "${ROOT}/assets/banner.txt" 2>/dev/null || echo "mac-dev-bootstrap"
  echo -e "${C_RESET}"

  if [[ "${NON_INTERACTIVE}" == "false" && -t 0 ]]; then
    interactive_setup
  else
    GIT_NAME="${GIT_NAME:-$(git config --global user.name 2>/dev/null || true)}"
    GIT_EMAIL="${GIT_EMAIL:-$(git config --global user.email 2>/dev/null || true)}"
  fi

  save_state \
    "THEME=${THEME}" \
    "USE_OH_MY_ZSH=${USE_OH_MY_ZSH}" \
    "FASTFETCH_ON_START=${FASTFETCH_ON_START}" \
    "INSTALL_TMUX=${INSTALL_TMUX}" \
    "INSTALL_NEOVIM=${INSTALL_NEOVIM}" \
    "INSTALL_GHOSTTY=${INSTALL_GHOSTTY}" \
    "GHOSTTY_DASHBOARD=${GHOSTTY_DASHBOARD}" \
    "PROMPT_STYLE=${PROMPT_STYLE}"

  export GIT_NAME GIT_EMAIL

  run_script backup_configs.sh
  run_script install_homebrew.sh
  run_script install_packages.sh
  run_script install_fonts.sh
  run_script configure_zsh.sh
  run_script configure_starship.sh
  run_script configure_git.sh
  run_script configure_fzf.sh
  run_script configure_zoxide.sh
  run_script configure_fastfetch.sh
  run_script configure_btop.sh
  run_script configure_kubernetes.sh
  run_script configure_docker.sh

  if [[ "${INSTALL_GHOSTTY}" == "true" ]]; then
    run_script configure_ghostty.sh
  fi
  if [[ "${INSTALL_TMUX}" == "true" ]]; then
    run_script configure_tmux.sh
  fi
  if [[ "${INSTALL_NEOVIM}" == "true" ]]; then
    run_script configure_neovim.sh
  fi

  mark_installed
  print_summary
}

main "$@"
