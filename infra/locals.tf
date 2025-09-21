locals {

  location_short_map = {
    "switzerlandnorth" = "swn"
    "westeurope"       = "weu"
    "northeurope"      = "neu"
  }

  location_short        = lookup(local.location_short_map, var.location, var.location)
  name_prefix           = "${var.workload_name}-${var.environment}-${local.location_short}"
  sanitized_name_prefix = replace(local.name_prefix, "-", "")

  tags = {
    environment = var.environment
    workload    = var.workload_name
    managed-by  = "Terraform"
  }

  rg_name                 = "rg-${local.name_prefix}"
  law_name                = "law-${local.name_prefix}"
  hub_vnet_name           = "vnet-${var.workload_name}-hub-${var.environment}-${local.location_short}"
  spoke_vnet_name         = "vnet-${local.name_prefix}"
  aks_name                = "aks-${local.name_prefix}"
  kv_name                 = "kv-${local.name_prefix}"
  storage_account_name    = "st${local.sanitized_name_prefix}"
  aks_runners_egress_name = "${local.name_prefix}-aks-runners-egress"
  firewall_name           = "afw-${local.name_prefix}"
  route_table_name        = "rt-${local.name_prefix}"
  route_name              = "rt-to-firewall"
  acr_name                = "acr${local.sanitized_name_prefix}"

}

