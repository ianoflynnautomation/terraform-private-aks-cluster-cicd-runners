variable "name" {
  description = "Specifies the firewall name"
  type        = string
}

variable "sku_name" {
  description = "(Required) SKU name of the Firewall. Possible values are AZFW_Hub and AZFW_VNet. Changing this forces a new resource to be created."
  default     = "AZFW_VNet"
  type        = string

  validation {
    condition     = contains(["AZFW_Hub", "AZFW_VNet"], var.sku_name)
    error_message = "The value of the sku name property of the firewall is invalid."
  }
}

variable "sku_tier" {
  description = "(Required) SKU tier of the Firewall. Possible values are Premium, Standard, and Basic."
  default     = "Standard"
  type        = string

  validation {
    condition     = contains(["Premium", "Standard", "Basic"], var.sku_tier)
    error_message = "The value of the sku tier property of the firewall is invalid."
  }
}

variable "resource_group_name" {
  description = "Specifies the resource group name"
  type        = string
}

variable "location" {
  description = "Specifies the location where firewall will be deployed"
  type        = string
}

variable "threat_intel_mode" {
  description = "(Optional) The operation mode for threat intelligence-based filtering. Possible values are: Off, Alert, Deny. Defaults to Alert."
  default     = "Alert"
  type        = string

  validation {
    condition     = contains(["Off", "Alert", "Deny"], var.threat_intel_mode)
    error_message = "The threat intel mode is invalid."
  }
}

variable "zones" {
  description = "Specifies the availability zones of the Azure Firewall"
  default     = ["1", "2", "3"]
  type        = list(string)
}

variable "pip_name" {
  description = "Specifies the firewall public IP name"
  type        = string
  default     = "azure-fw-ip"
}

variable "subnet_id" {
  description = "Subnet ID"
  type        = string
}

variable "tags" {
  description = "(Optional) Specifies the tags of the storage account"
  default     = {}
  type        = map(string)
}

variable "log_analytics_workspace_id" {
  description = "Specifies the log analytics workspace id"
  type        = string
}

variable "firewall_policy_name" {
  description = "Name of the firewall policy. Defaults to '{firewall_name}Policy'"
  type        = string
  default     = null
}

variable "dns_proxy_enabled" {
  description = "Enable DNS proxy in firewall policy"
  type        = bool
  default     = true
}

variable "threat_intelligence_mode" {
  description = "Threat intelligence mode for firewall policy. Possible values are: Off, Alert, Deny"
  type        = string
  default     = "Deny"

  validation {
    condition     = contains(["Off", "Alert", "Deny"], var.threat_intelligence_mode)
    error_message = "The threat intelligence mode is invalid."
  }
}

variable "rule_collection_groups" {
  description = "Map of firewall policy rule collection groups"
  type = map(object({
    priority = number
    application_rule_collections = optional(list(object({
      name     = string
      priority = number
      action   = string
      rules = list(object({
        name              = string
        source_addresses  = optional(list(string))
        source_ip_groups  = optional(list(string))
        destination_fqdns = list(string)
        protocols = list(object({
          type = string
          port = number
        }))
      }))
    })), [])
    network_rule_collections = optional(list(object({
      name     = string
      priority = number
      action   = string
      rules = list(object({
        name                  = string
        source_addresses      = optional(list(string))
        source_ip_groups      = optional(list(string))
        destination_ports     = list(string)
        destination_addresses = optional(list(string))
        destination_fqdns     = optional(list(string))
        protocols             = list(string)
      }))
    })), [])
    nat_rule_collections = optional(list(object({
      name     = string
      priority = number
      action   = string
      rules = list(object({
        name                = string
        source_addresses    = optional(list(string))
        source_ip_groups    = optional(list(string))
        destination_address = string
        destination_ports   = list(string)
        translated_address  = string
        translated_port     = string
        protocols           = list(string)
      }))
    })), [])
  }))
  default = {}
}

variable "enable_diagnostic_settings" {
  description = "Enable diagnostic settings for firewall and public IP"
  type        = bool
  default     = true
}

variable "diagnostic_log_categories" {
  description = "List of log categories to enable for firewall diagnostics"
  type        = list(string)
  default = [
    "AzureFirewallApplicationRule",
    "AzureFirewallNetworkRule",
    "AzureFirewallDnsProxy"
  ]
}

variable "pip_diagnostic_log_categories" {
  description = "List of log categories to enable for public IP diagnostics"
  type        = list(string)
  default = [
    "DDoSProtectionNotifications",
    "DDoSMitigationFlowLogs",
    "DDoSMitigationReports"
  ]
}