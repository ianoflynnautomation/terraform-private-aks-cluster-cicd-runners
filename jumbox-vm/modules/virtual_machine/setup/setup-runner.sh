#!/usr/bin/env bash
#
# GitHub Actions Runner Setup Script
# Installs and configures a self-hosted GitHub Actions runner for AKS jumpbox
# Based on GitHub's official create-latest-svc.sh best practices
#
# Usage: ./setup-runner.sh
# Environment Variables:
#   KEYVAULT_NAME - Azure Key Vault name (default: kv-myaks-dev-swn-002)
#   RUNNER_SCOPE - GitHub scope (default: ianoflynnautomation/terraform-private-aks-cluster-cicd-runners)
#   RUNNER_NAME - Runner name (default: hostname)
#   RUNNER_LABELS - Comma-separated labels (default: self-hosted,jumpbox,linux)
#   RUNNER_GROUP - Runner group name (optional)
#   SVC_USER - Service user (default: current user)
#   DEBUG - Enable verbose mode (default: 0)

set -euo pipefail
IFS=$'\n\t'

[[ "${DEBUG:-0}" == "1" ]] && set -x

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="/var/log/jumpbox-runner-setup.log"
readonly KEYVAULT_NAME="${KEYVAULT_NAME:-kv-myaks-dev-swn-002}"
readonly RUNNER_SCOPE="${RUNNER_SCOPE:-ianoflynnautomation/terraform-private-aks-cluster-cicd-runners}"
readonly RUNNER_NAME="${RUNNER_NAME:-$(hostname)}"
readonly RUNNER_LABELS="${RUNNER_LABELS:-self-hosted,jumpbox,linux}"
readonly RUNNER_GROUP="${RUNNER_GROUP:-}"
readonly SVC_USER="${SVC_USER:-adminuser}"
readonly RUNNER_DIR="/home/${SVC_USER}/runner"
readonly GITHUB_API_URL="https://api.github.com"

source "${SCRIPT_DIR}/logging.sh"

cleanup() {
  local exit_code=$?
  if [[ ${exit_code} -ne 0 ]]; then
    log_error "Setup failed with exit code: ${exit_code}"
  fi
}

trap cleanup EXIT

detect_architecture() {
  local runner_arch="x64"
  
  if arch | grep -q arm64; then
    runner_arch="arm64"
  fi
  
  echo "${runner_arch}"
}

check_prerequisites() {
  log_info "Checking prerequisites..."

  local missing_deps=()

  for cmd in az curl jq tar; do
    if ! command_exists "${cmd}"; then
      missing_deps+=("${cmd}")
    fi
  done

  if [[ ${#missing_deps[@]} -gt 0 ]]; then
    error_exit "Missing required dependencies: ${missing_deps[*]}"
  fi

  if ! az login --identity &>/dev/null; then
     error_exit "Azure CLI failed to login with Managed Identity. Check VM Identity permissions."
  fi

  if ! az account show &> /dev/null; then
    error_exit "Azure CLI not authenticated. Run 'az login' first."
  fi

  if [[ -d "${RUNNER_DIR}" ]]; then
    log_warn "Runner directory already exists: ${RUNNER_DIR}. Will attempt to re-configure."
  fi

  log_success "Prerequisites check passed"
}


fetch_github_token() {
  log_info "Fetching GitHub PAT from Key Vault: ${KEYVAULT_NAME}"
  
  local token
  token=$(az keyvault secret show \
    --vault-name "${KEYVAULT_NAME}" \
    --name "gh-flux-aks-token" \
    --query value \
    --output tsv 2>>"${LOG_FILE}") || {
    error_exit "Failed to fetch token from Key Vault '${KEYVAULT_NAME}'"
  }
  
  if [[ -z "${token}" || "${token}" == "null" ]]; then
    error_exit "Retrieved token is empty or null"
  fi
  
  export RUNNER_CFG_PAT="${token}"
  log_success "GitHub PAT fetched successfully"
}


get_registration_token() {
  log_info "Generating runner registration token..."
  
  local orgs_or_repos="repos"
  if [[ ! "${RUNNER_SCOPE}" == */* ]]; then
    orgs_or_repos="orgs"
  fi
  
  local api_url="${GITHUB_API_URL}/${orgs_or_repos}/${RUNNER_SCOPE}/actions/runners/registration-token"
  
  local reg_token
  reg_token=$(curl -fsSL \
    -X POST \
    -H "Accept: application/vnd.github.v3+json" \
    -H "Authorization: token ${RUNNER_CFG_PAT}" \
    "${api_url}" 2>>"${LOG_FILE}" | jq -r '.token') || {
    error_exit "Failed to fetch registration token from GitHub API"
  }
  
  if [[ -z "${reg_token}" || "${reg_token}" == "null" ]]; then
    error_exit "Invalid registration token received from GitHub"
  fi
  
  export RUNNER_TOKEN="${reg_token}"
  log_success "Registration token obtained"
}

download_runner() {
  log_info "Downloading latest runner release..."
  
  local runner_arch
  runner_arch=$(detect_architecture)
  
  local latest_version_label
  latest_version_label=$(curl -fsSL \
    -H "Accept: application/vnd.github.v3+json" \
    "${GITHUB_API_URL}/repos/actions/runner/releases/latest" | jq -r '.tag_name') || {
    error_exit "Failed to fetch latest runner version"
  }
  
  local latest_version="${latest_version_label:1}"
  local runner_file="actions-runner-linux-${runner_arch}-${latest_version}.tar.gz"
  local runner_url="https://github.com/actions/runner/releases/download/${latest_version_label}/${runner_file}"
  
  log_info "Latest version: ${latest_version}"
  
  if [[ -f "${runner_file}" ]]; then
    log_info "Runner tarball already exists: ${runner_file}"
  else
    log_info "Downloading from: ${runner_url}"
    curl -fsSL -o "${runner_file}" "${runner_url}" 2>>"${LOG_FILE}" || {
      error_exit "Failed to download runner from ${runner_url}"
    }
  fi
  
  log_info "Creating runner directory: ${RUNNER_DIR}"
  sudo -u "${SVC_USER}" mkdir -p "${RUNNER_DIR}"
  
  log_info "Extracting runner..."
  tar xzf "${runner_file}" -C "${RUNNER_DIR}" 2>>"${LOG_FILE}" || {
    error_exit "Failed to extract runner tarball"
  }
  
  sudo chown -R "${SVC_USER}" "${RUNNER_DIR}"
  
  log_success "Runner downloaded and extracted"
}

configure_runner() {
  log_info "Configuring runner: ${RUNNER_NAME}"
  
  local runner_url="https://github.com/${RUNNER_SCOPE}"
  
  cd "${RUNNER_DIR}" || error_exit "Failed to change to runner directory"
  
  local config_cmd=(
    ./config.sh
    --unattended
    --url "${runner_url}"
    --token "${RUNNER_TOKEN}"
    --name "${RUNNER_NAME}"
    --replace
  )
  
  [[ -n "${RUNNER_LABELS}" ]] && config_cmd+=(--labels "${RUNNER_LABELS}")
  [[ -n "${RUNNER_GROUP}" ]] && config_cmd+=(--runnergroup "${RUNNER_GROUP}")
  
  log_info "Running configuration..."
  sudo -E -u "${SVC_USER}" "${config_cmd[@]}" 2>>"${LOG_FILE}" || {
    error_exit "Runner configuration failed"
  }
  
  log_success "Runner configured successfully"
}

install_runner_service() {
  log_info "Installing runner as systemd service..."
  
  cd "${RUNNER_DIR}" || error_exit "Failed to change to runner directory"
  
  sudo ./svc.sh install "${SVC_USER}" 2>>"${LOG_FILE}" || {
    error_exit "Failed to install runner service"
  }
  
  sudo ./svc.sh start 2>>"${LOG_FILE}" || {
    error_exit "Failed to start runner service"
  }
  
  sleep 2
  
  log_success "Runner service installed and started"
}

verify_runner() {
  log_info "Verifying runner installation..."
  
  cd "${RUNNER_DIR}" || error_exit "Failed to change to runner directory"
  
  local status
  status=$(sudo ./svc.sh status 2>&1 || true)
  
  if echo "${status}" | grep -q "active (running)"; then
    log_success "Runner is active and running"
  else
    log_warn "Runner status: ${status}"
  fi
}

main() {
  log_info "========================================="
  log_info "GitHub Actions Runner Setup"
  log_info "========================================="
  log_info "Scope: ${RUNNER_SCOPE}"
  log_info "Name: ${RUNNER_NAME}"
  log_info "User: ${SVC_USER}"
  log_info "Labels: ${RUNNER_LABELS}"
  [[ -n "${RUNNER_GROUP}" ]] && log_info "Group: ${RUNNER_GROUP}"
  log_info "========================================="
  
  check_prerequisites
  fetch_github_token
  get_registration_token
  download_runner
  configure_runner
  install_runner_service
  verify_runner
  
  log_success "========================================="
  log_success "Runner setup completed successfully!"
  log_success "========================================="
  log_info "Runner directory: ${RUNNER_DIR}"
  log_info "Check status: sudo ${RUNNER_DIR}/svc.sh status"
  log_info "View logs: journalctl -u actions.runner.* -f"
  log_info "Stop runner: sudo ${RUNNER_DIR}/svc.sh stop"
  log_info "Uninstall: sudo ${RUNNER_DIR}/svc.sh uninstall"
}

main "$@"