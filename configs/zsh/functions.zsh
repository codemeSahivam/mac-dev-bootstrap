# Shell functions

# Fuzzy kubectl context (fzf)
kx() {
  command -v fzf &>/dev/null || { echo "fzf required"; return 1; }
  local ctx
  ctx="$(kubectl config get-contexts -o name 2>/dev/null | fzf --prompt='context> ')"
  [[ -n "${ctx}" ]] && kubectl config use-context "${ctx}" && echo "→ ${ctx}"
}

kls() { kubectl config get-contexts; }

# mkcd
mkcd() { mkdir -p "$1" && cd "$1" || return; }

# Extract archives
extract() {
  [[ -f "$1" ]] || { echo "not found: $1"; return 1; }
  case "$1" in
    *.tar.bz2) tar xjf "$1" ;;
    *.tar.gz)  tar xzf "$1" ;;
    *.tar.xz)  tar xJf "$1" ;;
    *.zip)     unzip "$1" ;;
    *.gz)      gunzip "$1" ;;
    *)         echo "unknown: $1" ;;
  esac
}

# Git branch cleanup
git-cleanup() {
  local branches
  branches="$(git branch --merged | sed '/\*/d' | sed -E '/main|master|develop/d' | xargs)"
  [[ -n "${branches}" ]] && git branch -d ${branches}
}

# Docker quick shell
dsh() {
  local c="${1:?container}"
  docker exec -it "${c}" /bin/sh 2>/dev/null || docker exec -it "${c}" /bin/bash
}

# Find listening port process
killport() {
  local port="${1:?port}"
  lsof -ti ":${port}" | xargs kill -9 2>/dev/null && echo "killed :${port}"
}
