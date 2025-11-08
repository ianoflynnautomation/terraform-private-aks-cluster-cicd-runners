variable "name" {
  description = "Specifies the name of the virtual machine"
  type        = string
}

variable "resource_group_name" {
  description = "Specifies the resource group name of the virtual machine"
  type        = string
}

variable "location" {
  description = "Specifies the location of the virtual machine"
  type        = string
}

variable "size" {
  description = "Specifies the size of the virtual machine"
  type        = string
}

variable "subnet_id" {
  description = "Specifies the resource id of the subnet hosting the virtual machine"
  type        = string
}

variable "admin_ssh_public_key" {
  description = "Specifies the public SSH key for admin user authentication"
  type        = string
  sensitive   = true
}

variable "network_security_group_id" {
  description = "The ID of the Network Security Group to associate with the NIC"
  type        = string
}

#--------------------------------------------------------------------------
# Optional Variables - VM Configuration
#--------------------------------------------------------------------------

variable "vm_user" {
  description = "Specifies the username of the virtual machine admin user"
  type        = string
  default     = "azadmin"
}

variable "computer_name" {
  description = "Specifies the hostname of the virtual machine. Defaults to var.name if not specified"
  type        = string
  default     = null
}

variable "custom_data" {
  description = "Specifies the custom data (cloud-init) for the virtual machine"
  type        = string
  default     = null
}

variable "os_disk_image" {
  description = "Specifies the OS disk image of the virtual machine"
  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}

variable "os_disk_storage_account_type" {
  description = "Specifies the storage account type of the OS disk"
  type        = string
  default     = "StandardSSD_LRS"

  validation {
    condition     = contains(["Premium_LRS", "Premium_ZRS", "StandardSSD_LRS", "StandardSSD_ZRS", "Standard_LRS"], var.os_disk_storage_account_type)
    error_message = "The storage account type must be one of: Premium_LRS, Premium_ZRS, StandardSSD_LRS, StandardSSD_ZRS, Standard_LRS."
  }
}

variable "os_disk_caching" {
  description = "Specifies the caching requirements for the OS disk"
  type        = string
  default     = "ReadWrite"

  validation {
    condition     = contains(["None", "ReadOnly", "ReadWrite"], var.os_disk_caching)
    error_message = "OS disk caching must be one of: None, ReadOnly, ReadWrite."
  }
}

variable "os_disk_size_gb" {
  description = "Specifies the size of the OS disk in GB. If null, uses image default"
  type        = number
  default     = null
}

variable "tags" {
  description = "Specifies the tags of the virtual machine"
  type        = map(string)
  default     = {}
}

#--------------------------------------------------------------------------
# Optional Variables - Networking
#--------------------------------------------------------------------------

variable "public_ip" {
  description = "Specifies whether to create a public IP for the virtual machine"
  type        = bool
  default     = false
}

variable "public_ip_name" {
  description = "Name for the public IP. Defaults to '{vm_name}PublicIp'"
  type        = string
  default     = null
}

variable "enable_accelerated_networking" {
  description = "Enable accelerated networking on the network interface"
  type        = bool
  default     = false
}

#--------------------------------------------------------------------------
# Optional Variables - Diagnostics & Monitoring
#--------------------------------------------------------------------------

variable "boot_diagnostics_storage_account" {
  description = "The Primary/Secondary Endpoint for the Azure Storage Account which should be used to store Boot Diagnostics"
  type        = string
  default     = null
}

variable "log_analytics_workspace_resource_id" {
  description = "Specifies the log analytics workspace resource id for monitoring"
  type        = string
  default     = null
}

variable "enable_azure_monitor_agent" {
  description = "Enable Azure Monitor Agent extension"
  type        = bool
  default     = true
}

variable "enable_dependency_agent" {
  description = "Enable Dependency Agent extension (requires Azure Monitor Agent)"
  type        = bool
  default     = true
}

variable "enable_data_collection_rule" {
  description = "Enable Data Collection Rule for VM Insights"
  type        = bool
  default     = true
}

variable "data_collection_rule_name" {
  description = "Name of the Data Collection Rule. Defaults to 'dcr-{vm_name}'"
  type        = string
  default     = null
}

variable "monitor_agent_version" {
  description = "Version of the Azure Monitor Linux Agent"
  type        = string
  default     = "1.25"
}

variable "dependency_agent_version" {
  description = "Version of the Dependency Agent"
  type        = string
  default     = "9.10"
}

#--------------------------------------------------------------------------
# Optional Variables - Identity
#--------------------------------------------------------------------------

variable "identity_type" {
  description = "The type of Managed Identity. Possible values are SystemAssigned, UserAssigned, SystemAssigned, UserAssigned"
  type        = string
  default     = "SystemAssigned"

  validation {
    condition     = contains(["SystemAssigned", "UserAssigned", "SystemAssigned, UserAssigned"], var.identity_type)
    error_message = "Identity type must be one of: SystemAssigned, UserAssigned, or 'SystemAssigned, UserAssigned'."
  }
}

variable "identity_ids" {
  description = "Specifies a list of user managed identity ids to be assigned. Required when identity_type is UserAssigned"
  type        = list(string)
  default     = []
}