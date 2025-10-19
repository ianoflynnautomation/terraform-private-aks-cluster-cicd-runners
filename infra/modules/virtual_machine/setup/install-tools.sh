#!/usr/bin/env bash
#
# Install third-party tools: Azure CLI, kubectl, helm, flux
# This script is idempotent and can be run multiple times safely
#
# Usage: ./install-tools.sh

set -euo pipefail
IFS=$'\n\t'

[[ "${DEBUG:-0}" == "1" ]] && set -x

readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly LOG_FILE="/var/log/jumpbox-setup.log"
readonly KUBECTL_VERSION="1.30"

source "${SCRIPT_DIR}/logging.sh"


install_azure_cli() {
  if command_exists az; then
    log_info "Azure CLI already installed"
    return 0
  fi
  
  log_info "Installing Azure CLI..."

  mkdir -p /etc/apt/trusted.gpg.d
  
  curl -sL https://packages.microsoft.com/keys/microsoft.asc | \
    gpg --dearmor -o /etc/apt/trusted.gpg.d/microsoft.gpg 2>>"${LOG_FILE}" || {
    error_exit "Failed to download Microsoft GPG key"
  }
  chmod 644 /etc/apt/trusted.gpg.d/microsoft.gpg
  
  local distro_codename
  distro_codename=$(lsb_release -cs)
  echo "deb [arch=amd64] https://packages.microsoft.com/repos/azure-cli/ ${distro_codename} main" | \
    tee /etc/apt/sources.list.d/azure-cli.list >/dev/null
  chmod 644 /etc/apt/sources.list.d/azure-cli.list

  apt-get update -y >>"${LOG_FILE}" 2>&1 || error_exit "apt-get update failed"
  DEBIAN_FRONTEND=noninteractive apt-get install -y azure-cli >>"${LOG_FILE}" 2>&1 || \
    error_exit "Failed to install Azure CLI"
  
  log_success "Azure CLI installed"
}

install_kubectl() {
  if command_exists kubectl; then
    log_info "kubectl already installed"
    return 0
  fi
  
  log_info "Installing kubectl v${KUBECTL_VERSION}..."
  
  mkdir -p /etc/apt/keyrings
  
  curl -fsSL "https://pkgs.k8s.io/core:/stable:/v${KUBECTL_VERSION}/deb/Release.key" | \
    gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg 2>>"${LOG_FILE}" || {
    error_exit "Failed to download Kubernetes GPG key"
  }
  chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg
  
  echo "deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v${KUBECTL_VERSION}/deb/ /" | \
    tee /etc/apt/sources.list.d/kubernetes.list >/dev/null
  chmod 644 /etc/apt/sources.list.d/kubernetes.list
  
  apt-get update -y >>"${LOG_FILE}" 2>&1 || error_exit "apt-get update failed"
  DEBIAN_FRONTEND=noninteractive apt-get install -y kubectl >>"${LOG_FILE}" 2>&1 || \
    error_exit "Failed to install kubectl"
  
  log_success "kubectl installed"
}


install_helm() {
  if command_exists helm; then
    log_info "Helm already installed"
    return 0
  fi
  
  log_info "Installing Helm..."
  
  mkdir -p /usr/share/keyrings
  
  curl -fsSL https://packages.buildkite.com/helm-linux/helm-debian/gpgkey | \
    gpg --dearmor -o /usr/share/keyrings/helm.gpg 2>>"${LOG_FILE}" || {
    error_exit "Failed to download Helm GPG key"
  }
  chmod 644 /usr/share/keyrings/helm.gpg
  
  echo "deb [signed-by=/usr/share/keyrings/helm.gpg] https://packages.buildkite.com/helm-linux/helm-debian/any/ any main" | \
    tee /etc/apt/sources.list.d/helm-stable-debian.list >/dev/null
  chmod 644 /etc/apt/sources.list.d/helm-stable-debian.list
  
  apt-get update -y >>"${LOG_FILE}" 2>&1 || error_exit "apt-get update failed"
  DEBIAN_FRONTEND=noninteractive apt-get install -y helm >>"${LOG_FILE}" 2>&1 || \
    error_exit "Failed to install Helm"
  
  log_success "Helm installed"
}

install_flux() {
  if command_exists flux; then
    log_info "Flux CLI already installed"
    return 0
  fi
  
  log_info "Installing Flux CLI..."
  
  curl -s https://fluxcd.io/install.sh | bash >>"${LOG_FILE}" 2>&1 || \
    error_exit "Failed to install Flux CLI"
  
  flux version >>"${LOG_FILE}" 2>&1 || error_exit "Flux installation verification failed"
  
  log_success "Flux CLI installed"
}


main() {
  log_info "Third-Party Tools Installation Starting"
  
  export DEBIAN_FRONTEND=noninteractive
  
  install_azure_cli || log_error "Azure CLI installation failed"
  install_kubectl || log_error "kubectl installation failed"
  install_helm || log_error "Helm installation failed"
  install_flux || log_error "Flux installation failed"
  
  log_success "Installation complete"
}

main "$@"