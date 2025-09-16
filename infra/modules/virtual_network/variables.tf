variable "location" {
  description = "(Required) Specifies the location of the virtual machine"
  type        = string
}

variable "resource_group_name" {
  description = "(Required) Specifies the name of the resource group"
  type        = string
}

variable "name" {
  description = "(Required) Specifies the name of the virtual network"
  type        = string
}

variable "address_space" {
  description = "VNET address space"
  type        = list(string)
}

variable "tags" {
  description = "(Optional) Specifies the tags of the virtual machine"
  default     = {}
}

variable "subnets" {
  description = "Subnets configuration"
  type = list(object({
    name                                          = string
    address_prefixes                              = list(string)
    private_link_service_network_policies_enabled = bool
    default_outbound_access_enabled               = bool
    delegation =string
    private_endpoint_network_policies             = string
  }))
}

variable "log_analytics_workspace_id" {
  description = "Specifies the log analytics workspace id"
  type        = string
}

variable "log_analytics_retention_days" {
  description = "Specifies the number of days of the retention policy"
  type        = number
  default     = 7
}
