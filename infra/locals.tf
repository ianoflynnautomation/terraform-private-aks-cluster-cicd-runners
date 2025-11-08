locals {
  location_short_map = {
    "switzerlandnorth" = "swn"
    "westeurope"       = "weu"
    "northeurope"      = "neu"
  }
  location_short        = lookup(local.location_short_map, var.location, var.location)
  name_suffix           = "${var.workload_name}-${var.environment}-${local.location_short}"
  sanitized_name_suffix = replace(local.name_suffix, "-", "")


  rg_name                   = "rg-${local.name_suffix}-003"
  law_name                  = "log-${local.name_suffix}-003"
  hub_vnet_name             = "vnet-${local.name_suffix}-hub-003"
  spoke_vnet_name           = "vnet-${local.name_suffix}-spoke-003"
  firewall_name             = "afw-${local.name_suffix}-003"
  route_table_name          = "rt-${local.name_suffix}-003"
  bastion_name              = "bas-${local.name_suffix}-003"
  aks_name                  = "aks-${local.name_suffix}-003"
  acr_name                  = "acr${local.sanitized_name_suffix}003"
  kv_name                   = "kv-${local.name_suffix}-003"
  vm_name                   = "vm-${local.name_suffix}-jumpbox-003"
  vm_nsg_name               = "nsg-${local.name_suffix}-jumpbox-003"
  vm_storage_account_name   = "st${local.sanitized_name_suffix}vmboot003"
  route_name                = "default-to-firewall"
  pe_nsg_name               = "nsg-${local.name_suffix}-pe-003"
  vm_scripts_container_name = "vmscripts"

  tags = {
    WorkloadName = var.workload_name
    Environment  = var.environment
    Region       = var.location
    CostCenter   = var.cost_center
    Owner        = var.owner
    ManagedBy    = "Terraform"
  }
}
