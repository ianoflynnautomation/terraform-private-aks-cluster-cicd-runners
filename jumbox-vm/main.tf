#--------------------------------------------------------------------------
# Core Infrastructure & Data Sources
#--------------------------------------------------------------------------

data "azurerm_client_config" "current" {}

data "azurerm_resource_group" "main" {
  name = local.rg_name
}

data "azurerm_log_analytics_workspace" "main" {
  name                = local.law_name
  resource_group_name = data.azurerm_resource_group.main.name
}

#--------------------------------------------------------------------------
# Networking Data Sources
#--------------------------------------------------------------------------

data "azurerm_virtual_network" "hub" {
  name                = local.hub_vnet_name
  resource_group_name = data.azurerm_resource_group.main.name
}

data "azurerm_subnet" "hub_bastion" {
  name                 = "AzureBastionSubnet"
  virtual_network_name = data.azurerm_virtual_network.hub.name
  resource_group_name  = data.azurerm_resource_group.main.name
}

data "azurerm_virtual_network" "spoke" {
  name                = local.spoke_vnet_name
  resource_group_name = data.azurerm_resource_group.main.name
}

data "azurerm_subnet" "vm" {
  name                 = "VmSubnet"
  virtual_network_name = data.azurerm_virtual_network.spoke.name
  resource_group_name  = data.azurerm_resource_group.main.name
}

data "azurerm_subnet" "pe" {
  name                 = "PrivateEndpointSubnet"
  virtual_network_name = data.azurerm_virtual_network.spoke.name
  resource_group_name  = data.azurerm_resource_group.main.name
}

#--------------------------------------------------------------------------
# VM Storage
#--------------------------------------------------------------------------

module "storage_account" {
  source              = "./modules/storage_account"
  name                = local.vm_storage_account_name
  location            = var.location
  resource_group_name = data.azurerm_resource_group.main.name
  account_kind        = var.storage_account_kind
  account_tier        = var.storage_account_tier
  replication_type    = var.storage_account_replication_type
  default_action      = "Deny"
  container_name      = local.vm_scripts_container_name
  tags                = local.tags
}

module "storage_blob_private_dns_zone" {
  source              = "./modules/private_dns_zone"
  name                = "privatelink.blob.core.windows.net"
  resource_group_name = data.azurerm_resource_group.main.name
  tags                = local.tags
  virtual_networks_to_link = {
    (data.azurerm_virtual_network.hub.name) = {
      subscription_id     = data.azurerm_client_config.current.subscription_id
      resource_group_name = data.azurerm_resource_group.main.name
    }
    (data.azurerm_virtual_network.spoke.name) = {
      subscription_id     = data.azurerm_client_config.current.subscription_id
      resource_group_name = data.azurerm_resource_group.main.name
    }
  }
}

module "storage_account_private_endpoint" {
  source                         = "./modules/private_endpoint"
  name                           = "${local.vm_storage_account_name}-pe"
  location                       = var.location
  resource_group_name            = data.azurerm_resource_group.main.name
  subnet_id                      = data.azurerm_subnet.pe.id
  tags                           = local.tags
  private_connection_resource_id = module.storage_account.id
  is_manual_connection           = false
  subresource_name               = "blob"
  private_dns_zone_group_name    = "default"
  private_dns_zone_group_ids     = [module.storage_blob_private_dns_zone.id]
}


#--------------------------------------------------------------------------
# Security & Identity
#--------------------------------------------------------------------------

resource "tls_private_key" "vm_ssh_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

data "azurerm_key_vault" "main" {
  name                = local.kv_name
  resource_group_name = data.azurerm_resource_group.main.name
}

resource "azurerm_key_vault_secret" "vm_ssh_public_key" {
  name         = "vm-ssh-public-key"
  value        = tls_private_key.vm_ssh_key.public_key_openssh
  key_vault_id = data.azurerm_key_vault.main.id
}

resource "azurerm_key_vault_secret" "vm_ssh_private_key" {
  name         = "vm-ssh-private-key"
  value        = tls_private_key.vm_ssh_key.private_key_pem
  key_vault_id = data.azurerm_key_vault.main.id
}

#--------------------------------------------------------------------------
# Container Services (AKS) Data Source
#--------------------------------------------------------------------------

data "azurerm_kubernetes_cluster" "main" {
  name                = local.aks_name
  resource_group_name = data.azurerm_resource_group.main.name
}

module "vm_nsg" {
  source                     = "./modules/network_security_group"
  name                       = local.vm_nsg_name
  location                   = var.location
  resource_group_name        = data.azurerm_resource_group.main.name
  log_analytics_workspace_id = data.azurerm_log_analytics_workspace.main.id
  tags                       = local.tags

  security_rules = [
    {
      name                       = "AllowBastionSSHInbound"
      priority                   = 100
      direction                  = "Inbound"
      access                     = "Allow"
      protocol                   = "Tcp"
      source_port_range          = "*"
      destination_port_range     = "22"
      source_address_prefix      = data.azurerm_subnet.hub_bastion.address_prefixes[0]
      destination_address_prefix = "*"
    },
    {
      name                       = "AllowInternetOutbound"
      priority                   = 200
      direction                  = "Outbound"
      access                     = "Allow"
      protocol                   = "*"
      source_port_range          = "*"
      destination_port_range     = "*"
      source_address_prefix      = "*"
      destination_address_prefix = "Internet"
    }
  ]
}


data "cloudinit_config" "vm_config" {
  gzip          = false
  base64_encode = true

  part {
    filename     = "cloud-config.yaml"
    content_type = "text/cloud-config"
    content      = file("${path.module}/modules/virtual_machine/setup/cloud-config.yaml")
  }
  part {
    filename     = "install-tools.sh"
    content_type = "text/x-shellscript"
    content      = file("${path.module}/modules/virtual_machine/setup/install-tools.sh")
  }
  part {
    filename     = "setup-runner.sh"
    content_type = "text/x-shellscript"
    content      = file("${path.module}/modules/virtual_machine/setup/setup-runner.sh")
  }
  part {
    filename     = "logging.sh"
    content_type = "text/x-shellscript"
    content      = file("${path.module}/modules/virtual_machine/setup/logging.sh")
  }
}

module "virtual_machine" {
  source                              = "./modules/virtual_machine"
  name                                = local.vm_name
  size                                = var.vm_size
  location                            = var.location
  public_ip                           = false
  vm_user                             = var.admin_username
  admin_ssh_public_key                = azurerm_key_vault_secret.vm_ssh_public_key.value
  os_disk_image                       = var.vm_os_disk_image
  resource_group_name                 = data.azurerm_resource_group.main.name
  subnet_id                           = data.azurerm_subnet.vm.id
  os_disk_storage_account_type        = var.vm_os_disk_storage_account_type
  boot_diagnostics_storage_account    = module.storage_account.primary_blob_endpoint
  log_analytics_workspace_id          = data.azurerm_log_analytics_workspace.main.id
  log_analytics_workspace_key         = data.azurerm_log_analytics_workspace.main.primary_shared_key
  log_analytics_workspace_resource_id = data.azurerm_log_analytics_workspace.main.id
  script_storage_account_name         = module.storage_account.name
  script_storage_account_key          = module.storage_account.primary_access_key
  container_name                      = module.storage_account.scripts_container_name
  script_name                         = var.script_name
  tags                                = local.tags
  network_security_group_id           = module.vm_nsg.id
  custom_data                         = data.cloudinit_config.vm_config.rendered
}

resource "azurerm_role_assignment" "jumpbox_vm_aks_access" {
  scope                = data.azurerm_kubernetes_cluster.main.id
  role_definition_name = "Azure Kubernetes Service Cluster User Role"
  principal_id         = module.virtual_machine.identity_principal_id
}

resource "azurerm_role_assignment" "vm_kv_secrets_user" {
  scope                = data.azurerm_key_vault.main.id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.virtual_machine.identity_principal_id
}