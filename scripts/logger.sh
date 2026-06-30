#!/usr/bin/env bash
# mac-dev-bootstrap — structured logging

: "${LOG_DIR:=${HOME}/.mac-dev-bootstrap/logs}"
: "${LOG_FILE:=${LOG_DIR}/install-$(date +%Y%m%d-%H%M%S).log}"

logger_init() {
  mkdir -p "${LOG_DIR}"
  touch "${LOG_FILE}"
}

_log_write() {
  local level="$1"
  shift
  printf '[%s] [%s] %s\n' "$(date '+%Y-%m-%d %H:%M:%S')" "${level}" "$*" >>"${LOG_FILE}" 2>/dev/null || true
}

log_debug() { _log_write DEBUG "$@"; }
log_info()  { _log_write INFO  "$@"; }
log_warn()  { _log_write WARN  "$@"; }
log_error() { _log_write ERROR "$@"; }
log_ok()    { _log_write OK    "$@"; }
