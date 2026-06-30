#!/usr/bin/env bash
# mac-dev-bootstrap — shared utilities

set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd)"
STATE_DIR="${HOME}/.mac-dev-bootstrap"
BACKUP_ROOT="${STATE_DIR}/backups"

# shellcheck source=logger.sh
source "${SCRIPT_DIR}/logger.sh"

# ── Colors & icons ────────────────────────────────────────────────────────────
if [[ -t 1 ]]; then
  C_RESET='\033[0m'
  C_BOLD='\033[1m'
  C_DIM='\033[2m'
  C_RED='\033[0;31m'
  C_GREEN='\033[0;32m'
  C_YELLOW='\033[1;33m'
  C_BLUE='\033[0;34m'
  C_CYAN='\033[0;36m'
  C_MAGENTA='\033[0;35m'
else
  C_RESET='' C_BOLD='' C_DIM='' C_RED='' C_GREEN='' C_YELLOW=''
  C_BLUE='' C_CYAN='' C_MAGENTA=''
fi

ICON_OK='✔'
ICON_FAIL='✖'
ICON_WARN='⚠'
ICON_INFO='▸'
ICON_STEP='━━━'

ui_step()    { echo -e "\n${C_CYAN}${C_BOLD}${ICON_STEP} $* ${ICON_STEP}${C_RESET}"; log_info "STEP: $*"; }
ui_info()    { echo -e "${C_BLUE}${C_BOLD}${ICON_INFO}${C_RESET} $*"; log_info "$*"; }
ui_success() { echo -e "${C_GREEN}${C_BOLD}${ICON_OK}${C_RESET} $*"; log_ok "$*"; }
ui_warn()    { echo -e "${C_YELLOW}${C_BOLD}${ICON_WARN}${C_RESET} $*"; log_warn "$*"; }
ui_error()   { echo -e "${C_RED}${C_BOLD}${ICON_FAIL}${C_RESET} $*" >&2; log_error "$*"; }
ui_dim()     { echo -e "${C_DIM}  $*${C_RESET}"; }

die() { ui_error "$@"; exit 1; }

# ── Platform ──────────────────────────────────────────────────────────────────
detect_arch() {
  case "$(uname -m)" in
    arm64)  echo "arm64" ;;
    x86_64) echo "x86_64" ;;
    *)      die "Unsupported architecture: $(uname -m)" ;;
  esac
}

is_apple_silicon() { [[ "$(detect_arch)" == "arm64" ]]; }

brew_prefix() {
  if is_apple_silicon; then echo "/opt/homebrew"; else echo "/usr/local"; fi
}

ensure_brew_path() {
  local prefix
  prefix="$(brew_prefix)"
  if [[ -x "${prefix}/bin/brew" ]]; then
    # shellcheck disable=SC1091
    eval "$("${prefix}/bin/brew" shellenv)"
  fi
}

command_exists() { command -v "$1" &>/dev/null; }

check_macos() {
  [[ "$(uname -s)" == "Darwin" ]] || die "This installer only supports macOS"
  local ver
  ver="$(sw_vers -productVersion)"
  ui_info "macOS ${ver} ($(detect_arch))"
  log_info "macOS version: ${ver}"
}

# ── Idempotent backup ─────────────────────────────────────────────────────────
backup_file() {
  local target="$1"
  [[ -e "${target}" ]] || return 0
  local stamp
  stamp="$(date +%Y%m%d%H%M%S)"
  local backup="${target}.backup.${stamp}"
  cp -R "${target}" "${backup}"
  ui_dim "Backed up ${target} → ${backup}"
  log_info "Backup: ${target} -> ${backup}"
  echo "${backup}"
}

# ── Idempotent deploy ─────────────────────────────────────────────────────────
# Deploy source to dest; skip if content identical (idempotent)
deploy_file() {
  local src="$1"
  local dest="$2"
  [[ -f "${src}" ]] || die "Missing config: ${src}"

  mkdir -p "$(dirname "${dest}")"

  if [[ -f "${dest}" ]] && cmp -s "${src}" "${dest}"; then
    ui_dim "Unchanged: ${dest}"
    return 0
  fi

  if [[ -e "${dest}" ]]; then
    backup_file "${dest}" >/dev/null
  fi

  cp "${src}" "${dest}"
  ui_dim "Deployed ${dest}"
  log_ok "Deployed ${src} -> ${dest}"
}

deploy_dir_link() {
  local src="$1"
  local dest="$2"
  [[ -d "${src}" ]] || die "Missing directory: ${src}"

  if [[ -L "${dest}" && "$(readlink "${dest}")" == "${src}" ]]; then
    ui_dim "Symlink OK: ${dest}"
    return 0
  fi

  if [[ -e "${dest}" ]]; then
    backup_file "${dest}" >/dev/null
    rm -rf "${dest}"
  fi

  ln -sf "${src}" "${dest}"
  ui_dim "Linked ${dest} → ${src}"
}

mark_installed() {
  mkdir -p "${STATE_DIR}"
  touch "${STATE_DIR}/installed"
  date -u +%Y-%m-%dT%H:%M:%SZ >>"${STATE_DIR}/install-history.log"
}

read_state() {
  local key="$1"
  local default="${2:-}"
  local file="${STATE_DIR}/config.env"
  if [[ -f "${file}" ]]; then
    # shellcheck disable=SC1090
    source "${file}"
  fi
  # shellcheck disable=SC2154
  printf '%s' "${!key:-$default}"
}

save_state() {
  local file="${STATE_DIR}/config.env"
  mkdir -p "${STATE_DIR}"
  : >"${file}"
  for kv in "$@"; do
    echo "${kv}" >>"${file}"
  done
}

prompt_choice() {
  local prompt="$1"
  shift
  local options=("$@")
  local i choice

  echo -e "${C_BOLD}${prompt}${C_RESET}"
  for i in "${!options[@]}"; do
    echo "  [$((i + 1))] ${options[$i]}"
  done

  while true; do
    read -r -p "Choice [1-${#options[@]}]: " choice
    if [[ "${choice}" =~ ^[0-9]+$ ]] && (( choice >= 1 && choice <= ${#options[@]} )); then
      REPLY="${options[$((choice - 1))]}"
      return 0
    fi
    ui_warn "Invalid choice. Try again."
  done
}

brew_install_formula() {
  local pkg="$1"
  ensure_brew_path
  if brew list "${pkg}" &>/dev/null; then
    ui_dim "  ${pkg} (installed)"
    return 0
  fi
  ui_info "  Installing ${pkg}..."
  if brew install "${pkg}" >>"${LOG_FILE}" 2>&1; then
    ui_success "  ${pkg}"
  else
    ui_warn "  Failed: ${pkg} (see log)"
    return 1
  fi
}

brew_install_cask() {
  local pkg="$1"
  ensure_brew_path
  if brew list --cask "${pkg}" &>/dev/null; then
    ui_dim "  ${pkg} (installed)"
    return 0
  fi
  ui_info "  Installing ${pkg}..."
  if brew install --cask "${pkg}" >>"${LOG_FILE}" 2>&1; then
    ui_success "  ${pkg}"
  else
    ui_warn "  Failed: ${pkg} (see log)"
    return 1
  fi
}
