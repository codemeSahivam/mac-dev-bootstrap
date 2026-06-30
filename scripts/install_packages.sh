#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=utils.sh
source "${SCRIPT_DIR}/utils.sh"

logger_init
ensure_brew_path

FORMULAE=(
  starship fastfetch eza bat fzf fd ripgrep jq yq tree btop
  git-delta lazygit zoxide tmux neovim wget curl htop
  kubectl helm kubectx kubens
)

CASKS=()
if [[ "${INSTALL_GHOSTTY:-true}" == "true" ]]; then
  CASKS+=(ghostty)
fi
CASKS+=(font-jetbrains-mono-nerd-font)

ui_step "Installing Homebrew formulae"
for pkg in "${FORMULAE[@]}"; do
  brew_install_formula "${pkg}" || true
done

if [[ "${INSTALL_NEOVIM:-true}" != "true" ]]; then
  ui_dim "Skipping neovim (disabled)"
fi

ui_step "Installing Homebrew casks"
for pkg in "${CASKS[@]}"; do
  brew_install_cask "${pkg}" || true
done

# Docker Desktop is large — install formula for CLI; user can install Desktop separately
if ! command_exists docker; then
  brew_install_formula docker 2>/dev/null || ui_dim "Docker CLI optional — install Docker Desktop manually if needed"
fi

ui_success "Package installation complete"
