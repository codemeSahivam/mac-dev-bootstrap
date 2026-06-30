#!/usr/bin/env bash
set -Eeuo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=utils.sh
source "${SCRIPT_DIR}/utils.sh"

logger_init

mkdir -p "${HOME}/.kube/configs"
mkdir -p "${HOME}/.config/mac-dev-bootstrap"

cat >"${HOME}/.config/mac-dev-bootstrap/kube-env.sh" <<'EOF'
# Merge kubeconfigs from ~/.kube/configs/
_kube_configs_dir="${HOME}/.kube/configs"
if [[ -d "${_kube_configs_dir}" ]]; then
  _files=("${_kube_configs_dir}"/*.{yaml,yml}(N))
  if (( ${#_files[@]} )); then
    export KUBECONFIG="${(j.:.)_files}"
  fi
fi
unset _kube_configs_dir _files
EOF

ui_success "Kubernetes helpers ready"
ui_dim "Place configs in ~/.kube/configs/ — use kctx, kns, kx aliases"
