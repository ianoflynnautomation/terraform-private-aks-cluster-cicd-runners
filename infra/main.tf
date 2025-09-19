
data "azurerm_client_config" "current" {}

# ------------------------------------------------------------------------------------------------------
# Resource Group: Central resource container for the workload
# ------------------------------------------------------------------------------------------------------

resource "azurerm_resource_group" "main" {
  name     = local.rg_name
  location = var.location
  tags     = local.tags
}

# ------------------------------------------------------------------------------------------------------
# Monitoring: Log Analytics Workspace for collecting logs and metrics
# ------------------------------------------------------------------------------------------------------

module "log_analytics_workspace" {
  source              = "./modules/log_analytics_workspace"
  name                = local.law_name
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  solution_plan_map   = var.solution_plan_map
  tags                = local.tags
}

# ------------------------------------------------------------------------------------------------------
# Networking: Hub and Spoke virtual networks
# ------------------------------------------------------------------------------------------------------

module "hub_vnet" {
  source                     = "./modules/virtual_network"
  name                       = local.hub_vnet_name
  address_space              = var.vm_vnet_address_space
  location                   = var.location
  resource_group_name        = azurerm_resource_group.main.name
  log_analytics_workspace_id = module.log_analytics_workspace.id
  tags                       = local.tags

  subnets = [
    {
      name : var.default_node_pool_subnet_name
      address_prefixes : var.default_node_pool_subnet_address_prefix
      private_link_service_network_policies_enabled : false
      default_outbound_access_enabled : true
      delegation = null
      private_endpoint_network_policies : "Enabled"
    },
    {
      name : var.additional_node_pool_subnet_name
      address_prefixes : var.additional_node_pool_subnet_address_prefix
      private_link_service_network_policies_enabled : false
      default_outbound_access_enabled : true
      delegation = null
      private_endpoint_network_policies : "Enabled"
    },
    {
      name : var.pod_subnet_name
      address_prefixes : var.pod_subnet_address_prefix
      private_link_service_network_policies_enabled : false
      default_outbound_access_enabled : true
      delegation = null
      private_endpoint_network_policies : "Enabled"

    }
  ]
}

module "spoke_vnet" {
  source                     = "./modules/virtual_network"
  name                       = local.spoke_vnet_name
  address_space              = var.hub_vnet_address_space
  location                   = var.location
  resource_group_name        = azurerm_resource_group.main.name
  log_analytics_workspace_id = module.log_analytics_workspace.id
  tags                       = local.tags

  subnets = [{
    name : "AzureFirewallSubnet"
    address_prefixes : var.hub_firewall_subnet_address_prefix
    private_endpoint_network_policies_enabled : true
    private_link_service_network_policies_enabled : false
    default_outbound_access_enabled : true
    delegation : null
    private_endpoint_network_policies : "Enabled"
    }
  ]
}

module "vnet_peering" {
  source              = "./modules/virtual_network_peering"
  peering_name_1_to_2 = "peer-${module.hub_vnet.name}-to-${module.spoke_vnet.name}"
  vnet_1_rg           = azurerm_resource_group.main.name
  vnet_1_name         = module.hub_vnet.name
  vnet_1_id           = module.hub_vnet.vnet_id

  peering_name_2_to_1 = "peer-${module.spoke_vnet.name}-to-${module.hub_vnet.name}"
  vnet_2_rg           = azurerm_resource_group.main.name
  vnet_2_name         = module.spoke_vnet.name
  vnet_2_id           = module.spoke_vnet.vnet_id
}

# ------------------------------------------------------------------------------------------------------
# AKS Cluster: The core Kubernetes service
# ------------------------------------------------------------------------------------------------------

module "aks_cluster" {
  source                               = "./modules/aks"
  name                                 = local.aks_name
  location                             = var.location
  resource_group_name                  = azurerm_resource_group.main.name
  resource_group_id                    = azurerm_resource_group.main.id
  kubernetes_version                   = var.kubernetes_version
  dns_prefix                           = lower(var.aks_cluster_name)
  private_cluster_enabled              = true
  automatic_channel_upgrade            = var.automatic_channel_upgrade
  sku_tier                             = var.sku_tier
  default_node_pool_name               = var.default_node_pool_name
  default_node_pool_vm_size            = var.default_node_pool_vm_size
  vnet_subnet_id                       = module.hub_vnet.subnet_ids[var.default_node_pool_subnet_name]
  default_node_pool_availability_zones = var.default_node_pool_availability_zones
  # default_node_pool_node_labels            = var.default_node_pool_node_labels
  # default_node_pool_node_taints            = var.default_node_pool_node_taints
  default_node_pool_enable_auto_scaling    = var.default_node_pool_enable_auto_scaling
  default_node_pool_enable_host_encryption = var.default_node_pool_enable_host_encryption
  default_node_pool_enable_node_public_ip  = var.default_node_pool_enable_node_public_ip
  default_node_pool_max_pods               = var.default_node_pool_max_pods
  default_node_pool_max_count              = var.default_node_pool_max_count
  default_node_pool_min_count              = var.default_node_pool_min_count
  default_node_pool_node_count             = var.default_node_pool_node_count
  default_node_pool_os_disk_type           = var.default_node_pool_os_disk_type
  tags                                     = local.tags
  network_dns_service_ip                   = var.network_dns_service_ip
  network_plugin                           = var.network_plugin
  outbound_type                            = "userDefinedRouting"
  network_service_cidr                     = var.network_service_cidr
  log_analytics_workspace_id               = module.log_analytics_workspace.id
  role_based_access_control_enabled        = var.role_based_access_control_enabled
  tenant_id                                = data.azurerm_client_config.current.tenant_id
  admin_group_object_ids                   = var.admin_group_object_ids
  azure_rbac_enabled                       = var.azure_rbac_enabled
  admin_username                           = var.admin_username
  ssh_public_key                           = azurerm_key_vault_secret.ssh_public_key.value
  keda_enabled                             = var.keda_enabled
  vertical_pod_autoscaler_enabled          = var.vertical_pod_autoscaler_enabled
  workload_identity_enabled                = var.workload_identity_enabled
  oidc_issuer_enabled                      = var.oidc_issuer_enabled
  open_service_mesh_enabled                = var.open_service_mesh_enabled
  image_cleaner_enabled                    = var.image_cleaner_enabled
  azure_policy_enabled                     = var.azure_policy_enabled
  http_application_routing_enabled         = var.http_application_routing_enabled

  depends_on = [module.routetable]
}

module "node_pool" {
  source                 = "./modules/node_pool"
  resource_group_name    = azurerm_resource_group.main.name
  kubernetes_cluster_id  = module.aks_cluster.id
  name                   = var.additional_node_pool_name
  vm_size                = var.additional_node_pool_vm_size
  mode                   = var.additional_node_pool_mode
  node_labels            = var.additional_node_pool_node_labels
  node_taints            = var.additional_node_pool_node_taints
  availability_zones     = var.additional_node_pool_availability_zones
  vnet_subnet_id         = module.hub_vnet.subnet_ids[var.additional_node_pool_subnet_name]
  enable_auto_scaling    = var.additional_node_pool_enable_auto_scaling
  enable_host_encryption = var.additional_node_pool_enable_host_encryption
  enable_node_public_ip  = var.additional_node_pool_enable_node_public_ip
  orchestrator_version   = var.kubernetes_version
  max_pods               = var.additional_node_pool_max_pods
  max_count              = var.additional_node_pool_max_count
  min_count              = var.additional_node_pool_min_count
  node_count             = var.additional_node_pool_node_count
  os_type                = var.additional_node_pool_os_type
  priority               = var.additional_node_pool_priority
  tags                   = local.tags

  depends_on = [module.routetable]
}

module "firewall" {
  source                     = "./modules/firewall"
  name                       = var.firewall_name
  resource_group_name        = azurerm_resource_group.main.name
  zones                      = var.firewall_zones
  threat_intel_mode          = var.firewall_threat_intel_mode
  location                   = var.location
  sku_name                   = var.firewall_sku_name
  sku_tier                   = var.firewall_sku_tier
  pip_name                   = "${var.firewall_name}PublicIp"
  subnet_id                  = module.spoke_vnet.subnet_ids["AzureFirewallSubnet"]
  log_analytics_workspace_id = module.log_analytics_workspace.id
}



module "routetable" {
  source              = "./modules/route_table"
  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  route_table_name    = local.route_table_name
  route_name          = local.route_name
  firewall_private_ip = module.firewall.private_ip_address
  subnets_to_associate = {
    (var.default_node_pool_subnet_name) = {
      subscription_id      = data.azurerm_client_config.current.subscription_id
      resource_group_name  = azurerm_resource_group.main.name
      virtual_network_name = module.hub_vnet.name
    }
    (var.additional_node_pool_subnet_name) = {
      subscription_id      = data.azurerm_client_config.current.subscription_id
      resource_group_name  = azurerm_resource_group.main.name
      virtual_network_name = module.hub_vnet.name
    }
  }
}

# ------------------------------------------------------------------------------------------------------
# Secrets Management: Key Vault for storing sensitive information
# ------------------------------------------------------------------------------------------------------


module "key_vault" {

  source                          = "./modules/key_vault"
  name                            = local.kv_name
  location                        = var.location
  resource_group_name             = azurerm_resource_group.main.name
  tenant_id                       = data.azurerm_client_config.current.tenant_id
  sku_name                        = var.key_vault_sku_name
  tags                            = local.tags
  enabled_for_deployment          = var.key_vault_enabled_for_deployment
  enabled_for_disk_encryption     = var.key_vault_enabled_for_disk_encryption
  enabled_for_template_deployment = var.key_vault_enabled_for_template_deployment
  enable_rbac_authorization       = var.key_vault_enable_rbac_authorization
  purge_protection_enabled        = var.key_vault_purge_protection_enabled
  soft_delete_retention_days      = var.key_vault_soft_delete_retention_days
  bypass                          = var.key_vault_bypass
  default_action                  = var.key_vault_default_action
  log_analytics_workspace_id      = module.log_analytics_workspace.id

}

resource "azurerm_role_assignment" "key_vault_secrets_officer" {
  scope                = module.key_vault.id
  role_definition_name = "Key Vault Secrets Officer"
  principal_id         = data.azurerm_client_config.current.object_id
}

resource "azurerm_key_vault_secret" "ssh_public_key" {
  name         = "aks-ssh-public-key"
  value        = tls_private_key.ssh_key_pair.public_key_openssh
  key_vault_id = module.key_vault.id
  depends_on   = [azurerm_role_assignment.key_vault_secrets_officer]
}

resource "azurerm_key_vault_secret" "ssh_private_key" {
  name         = "aks-ssh-private-key"
  value        = tls_private_key.ssh_key_pair.private_key_pem
  key_vault_id = module.key_vault.id
  depends_on   = [azurerm_role_assignment.key_vault_secrets_officer]
}

resource "tls_private_key" "ssh_key_pair" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

