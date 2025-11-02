variable "location" {
  description = "(Required) The Azure region where all resources will be created."
  type        = string
  default     = "switzerlandnorth"
}

variable "environment" {
  description = "(Required) The deployment environment (e.g., 'dev', 'tst', 'prd')."
  type        = string
  default     = "dev"
}

variable "workload_name" {
  description = "(Required) The name of the application or workload (e.g., 'webapp', 'data-platform')."
  type        = string
  default     = "myaks"
}

variable "cost_center" {
  description = "(Optional) The cost center responsible for this deployment."
  type        = string
  default     = "InfraTeam-12345"
}

variable "owner" {
  description = "(Optional) The name or email of the person or team responsible for this deployment."
  type        = string
  default     = "team@example.com"
}


variable "vm_size" {
  description = "(Optional) The VM size for the self-hosted agent virtual machine."
  type        = string
  default     = "Standard_DS1_v2"
}

variable "admin_username" {
  description = "(Required) The admin username for the self-hosted agent VM and AKS worker nodes."
  type        = string
  default     = "adminuser"
}

variable "vm_os_disk_image" {
  description = "(Optional) The OS disk image configuration for the virtual machine."
  type        = map(string)
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}

variable "vm_os_disk_storage_account_type" {
  description = "(Optional) The storage account type for the OS disk of the virtual machine."
  type        = string
  default     = "Premium_LRS"

  validation {
    condition     = contains(["Premium_LRS", "Premium_ZRS", "StandardSSD_LRS", "StandardSSD_ZRS", "Standard_LRS"], var.vm_os_disk_storage_account_type)
    error_message = "Allowed values for vm_os_disk_storage_account_type are 'Premium_LRS', 'Premium_ZRS', 'StandardSSD_LRS', 'StandardSSD_ZRS', or 'Standard_LRS'."
  }
}


variable "script_name" {
  description = "(Required) The name of the custom script for the self-hosted agent."
  type        = string
  default     = "configure-self-hosted-agent.sh"
}

# Storage Account Variables
variable "storage_account_kind" {
  description = "(Optional) The kind of storage account to create."
  type        = string
  default     = "StorageV2"

  validation {
    condition     = contains(["Storage", "StorageV2"], var.storage_account_kind)
    error_message = "Allowed values for storage_account_kind are 'Storage' or 'StorageV2'."
  }
}

variable "storage_account_replication_type" {
  description = "(Optional) The replication type for the storage account."
  type        = string
  default     = "LRS"

  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "GZRS", "RA-GRS", "RA-GZRS"], var.storage_account_replication_type)
    error_message = "Allowed values for storage_account_replication_type are 'LRS', 'ZRS', 'GRS', 'GZRS', 'RA-GRS', or 'RA-GZRS'."
  }
}

variable "storage_account_tier" {
  description = "(Optional) The tier of the storage account."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "Allowed values for storage_account_tier are 'Standard' or 'Premium'."
  }
}

variable "management_policy_rules" {
  description = "(Optional) The management policy rules for the storage account."
  type        = list(any)
  default = [
    {
      name    = "scripts_container_management_policy"
      enabled = true
      filters = {
        prefix_match = ["scripts"]
        blob_types   = ["blockBlob"]
      }
      actions = {
        base_blob = {
          tier_to_cool_after_days_since_modification_greater_than    = 30
          tier_to_archive_after_days_since_modification_greater_than = 60
          delete_after_days_since_modification_greater_than          = 90
        }
        snapshot = {
          change_tier_to_archive_after_days_since_creation = 30
          change_tier_to_cool_after_days_since_creation    = 60
          delete_after_days_since_creation_greater_than    = 90
        }
        version = {
          change_tier_to_archive_after_days_since_creation = 30
          change_tier_to_cool_after_days_since_creation    = 60
          delete_after_days_since_creation                 = 90
        }
      }
    }
  ]
}