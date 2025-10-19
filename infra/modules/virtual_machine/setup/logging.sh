#!/usr/bin/env bash
#
# Shared logging library for bash scripts
# Source this file to use logging functions
#
# Usage: source "$(dirname "$0")/logging.sh"

: "${LOG_FILE:=/var/log/script.log}"

readonly LOG_LEVEL_INFO="INFO"
readonly LOG_LEVEL_ERROR="ERROR"
readonly LOG_LEVEL_WARN="WARN"
readonly LOG_LEVEL_SUCCESS="SUCCESS"

_log() {
  local level="$1"
  shift
  local timestamp
  timestamp="$(date '+%Y-%m-%d %H:%M:%S')"
  echo "[${level}] [${timestamp}] $*" | tee -a "${LOG_FILE}"
}


log_info() {
  _log "${LOG_LEVEL_INFO}" "$@"
}


log_error() {
  _log "${LOG_LEVEL_ERROR}" "$@" >&2
}


log_warn() {
  _log "${LOG_LEVEL_WARN}" "$@"
}


log_success() {
  _log "${LOG_LEVEL_SUCCESS}" "$@"
}

command_exists() {
  command -v "$1" &> /dev/null
}

error_exit() {
  log_error "$1"
  exit "${2:-1}"
}