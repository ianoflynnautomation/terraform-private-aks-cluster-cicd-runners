# General and Tagging Variables
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

variable "admin_username" {
  description = "(Required) The admin username for the self-hosted agent VM and AKS worker nodes."
  type        = string
  default     = "adminuser"
}

# Networking Variables
variable "hub_vnet_address_space" {
  description = "(Optional) The address space for the hub virtual network."
  type        = list(string)
  default     = ["10.1.0.0/16"]
}

variable "vm_vnet_address_space" {
  description = "(Optional) The address space for the spoke virtual network."
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "spoke_vnet_subnets" {
  description = "(Optional) A map of subnets to create in the spoke VNet."
  type        = any
  default = {
    "AksNodes" = {
      address_prefixes = ["10.1.0.0/24"]
    },
    "AksPods" = {
      address_prefixes = ["10.1.1.0/24"]
    }
  }
}

variable "pod_subnet_name" {
  description = "(Optional) The name of the pod subnet."
  type        = string
  default     = "PodSubnet"
}

variable "pod_subnet_address_prefix" {
  description = "(Optional) The address prefix for the pod subnet."
  type        = list(string)
  default     = ["10.0.32.0/20"]
}

variable "default_node_pool_subnet_name" {
  description = "(Optional) The name of the subnet hosting the default node pool."
  type        = string
  default     = "SystemSubnet"
}

variable "default_node_pool_subnet_address_prefix" {
  description = "(Optional) The address prefix for the subnet hosting the default node pool."
  type        = list(string)
  default     = ["10.0.0.0/20"]
}

variable "additional_node_pool_subnet_name" {
  description = "(Optional) The name of the subnet hosting the additional node pool."
  type        = string
  default     = "UserSubnet"
}

variable "additional_node_pool_subnet_address_prefix" {
  description = "(Optional) The address prefix for the subnet hosting the additional node pool."
  type        = list(string)
  default     = ["10.0.16.0/20"]
}

variable "runner_node_pool_subnet_name" {
  description = "(Optional) The name of the subnet hosting the runner node pool."
  type        = string
  default     = "RunnerSubnet"
}

variable "runner_node_pool_subnet_address_prefix" {
  description = "(Optional) The address prefix for the subnet hosting the runner node pool."
  type        = list(string)
  default     = ["10.0.48.0/20"]
}

variable "vm_subnet_address_prefix" {
  description = "(Optional) The address prefix for the jumpbox subnet."
  type        = list(string)
  default     = ["10.0.16.0/20"]
}

variable "hub_firewall_subnet_address_prefix" {
  description = "(Optional) The address prefix for the firewall subnet in the hub VNet."
  type        = list(string)
  default     = ["10.1.0.0/24"]
}

variable "hub_bastion_subnet_address_prefix" {
  description = "(Optional) The address prefix for the bastion subnet in the hub VNet."
  type        = list(string)
  default     = ["10.1.1.0/24"]
}

variable "pe_subnet_address_prefix" {
  description = "(Optional) The address prefix for the private endpoints subnet."
  type        = list(string)
  default     = ["10.0.64.0/27"]
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

# Log Analytics Workspace Variables
variable "log_analytics_workspace_name" {
  description = "(Optional) The name of the Log Analytics workspace."
  type        = string
  default     = "TestWorkspace"
}

variable "solution_plan_map" {
  description = "(Optional) The solutions to deploy to the Log Analytics workspace."
  type        = map(any)
  default = {
    ContainerInsights = {
      publisher = "Microsoft"
      product   = "OMSGallery/ContainerInsights"
    }
  }
}

# Key Vault Variables
variable "key_vault_name" {
  description = "(Required) The name of the Key Vault."
  type        = string
  default     = "KeyVault01"
}

variable "key_vault_sku_name" {
  description = "(Required) The SKU name for the Key Vault. Allowed values: 'standard', 'premium'."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku_name)
    error_message = "Allowed values for key_vault_sku_name are 'standard' or 'premium'."
  }
}

variable "key_vault_enabled_for_deployment" {
  description = "(Optional) Whether Azure VMs can retrieve certificates from the Key Vault. Defaults to true."
  type        = bool
  default     = true
}

variable "key_vault_enabled_for_disk_encryption" {
  description = "(Optional) Whether Azure Disk Encryption can retrieve secrets from the Key Vault. Defaults to true."
  type        = bool
  default     = true
}

variable "key_vault_enabled_for_template_deployment" {
  description = "(Optional) Whether Azure Resource Manager can retrieve secrets from the Key Vault. Defaults to true."
  type        = bool
  default     = true
}

variable "key_vault_enable_rbac_authorization" {
  description = "(Optional) Whether to enable RBAC authorization for the Key Vault. Defaults to true."
  type        = bool
  default     = true
}

variable "key_vault_purge_protection_enabled" {
  description = "(Optional) Whether purge protection is enabled for the Key Vault. Defaults to true."
  type        = bool
  default     = false # changes to false for testing
}

variable "key_vault_soft_delete_retention_days" {
  description = "(Optional) The retention period in days for soft-deleted items (7-90). Defaults to 30."
  type        = number
  default     = 30

  validation {
    condition     = var.key_vault_soft_delete_retention_days >= 7 && var.key_vault_soft_delete_retention_days <= 90
    error_message = "key_vault_soft_delete_retention_days must be between 7 and 90."
  }
}

variable "key_vault_bypass" {
  description = "(Required) Specifies which traffic can bypass network rules. Allowed values: 'AzureServices', 'None'."
  type        = string
  default     = "AzureServices"

  validation {
    condition     = contains(["AzureServices", "None"], var.key_vault_bypass)
    error_message = "Allowed values for key_vault_bypass are 'AzureServices' or 'None'."
  }
}

variable "key_vault_default_action" {
  description = "(Required) The default action when no network rules match. Allowed values: 'Allow', 'Deny'."
  type        = string
  default     = "Allow"

  validation {
    condition     = contains(["Allow", "Deny"], var.key_vault_default_action)
    error_message = "Allowed values for key_vault_default_action are 'Allow' or 'Deny'."
  }
}

# AKS Cluster Variables
variable "aks_cluster_name" {
  description = "(Required) The name of the AKS cluster."
  type        = string
  default     = "BaboAks"
}

variable "kubernetes_version" {
  description = "(Optional) The Kubernetes version for the AKS cluster."
  type        = string
  default     = "1.33.2"
}

variable "network_dns_service_ip" {
  description = "(Optional) The DNS service IP for the AKS cluster."
  type        = string
  default     = "10.2.0.10"
}

variable "network_service_cidr" {
  description = "(Optional) The service CIDR for the AKS cluster."
  type        = string
  default     = "10.2.0.0/24"
}

variable "network_plugin" {
  description = "(Optional) The network plugin for the AKS cluster. Defaults to 'azure'."
  type        = string
  default     = "azure"
}

variable "automatic_channel_upgrade" {
  description = "(Optional) The upgrade channel for the AKS cluster. Allowed values: 'patch', 'rapid', 'stable'."
  type        = string
  default     = "stable"

  validation {
    condition     = contains(["patch", "rapid", "stable"], var.automatic_channel_upgrade)
    error_message = "Allowed values for automatic_channel_upgrade are 'patch', 'rapid', or 'stable'."
  }
}

variable "sku_tier" {
  description = "(Optional) The SKU tier for the AKS cluster. Allowed values: 'Free', 'Paid'."
  type        = string
  default     = "Free"

  validation {
    condition     = contains(["Free", "Paid"], var.sku_tier)
    error_message = "Allowed values for sku_tier are 'Free' or 'Paid'."
  }
}

variable "role_based_access_control_enabled" {
  description = "(Required) Whether Role Based Access Control is enabled for the AKS cluster."
  type        = bool
  default     = true
}

variable "admin_group_object_ids" {
  description = "(Optional) A list of Microsoft Entra ID group object IDs with admin role on the cluster."
  type        = list(string)
  default     = ["6e5de8c1-5a4b-409b-994f-0706e4403b77", "78761057-c58c-44b7-aaa7-ce1639c6c4f5"]
}

variable "azure_rbac_enabled" {
  description = "(Optional) Whether Azure RBAC is enabled for the AKS cluster."
  type        = bool
  default     = true
}

variable "keda_enabled" {
  description = "(Optional) Whether KEDA autoscaler is enabled for the AKS cluster."
  type        = bool
  default     = true
}

variable "vertical_pod_autoscaler_enabled" {
  description = "(Optional) Whether Vertical Pod Autoscaler is enabled for the AKS cluster."
  type        = bool
  default     = true
}

variable "workload_identity_enabled" {
  description = "(Optional) Whether Microsoft Entra ID Workload Identity is enabled for the AKS cluster."
  type        = bool
  default     = true
}

variable "oidc_issuer_enabled" {
  description = "(Optional) Whether the OIDC issuer URL is enabled for the AKS cluster."
  type        = bool
  default     = true
}

variable "open_service_mesh_enabled" {
  description = "(Optional) Whether Open Service Mesh is enabled for the AKS cluster."
  type        = bool
  default     = true
}

variable "image_cleaner_enabled" {
  description = "(Optional) Whether Image Cleaner is enabled for the AKS cluster."
  type        = bool
  default     = true
}

variable "azure_policy_enabled" {
  description = "(Optional) Whether Azure Policy add-on is enabled for the AKS cluster."
  type        = bool
  default     = true
}

variable "http_application_routing_enabled" {
  description = "(Optional) Whether HTTP Application Routing is enabled for the AKS cluster."
  type        = bool
  default     = false
}

# AKS Default Node Pool Variables
variable "default_node_pool_name" {
  description = "(Optional) The name of the default node pool."
  type        = string
  default     = "system"
}

variable "default_node_pool_vm_size" {
  description = "(Required) The VM size for nodes in the default node pool."
  type        = string
  default     = "Standard_F8s_v2"
}

variable "default_node_pool_availability_zones" {
  description = "(Optional) The availability zones for the default node pool."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "default_node_pool_enable_auto_scaling" {
  description = "(Optional) Whether auto-scaling is enabled for the default node pool."
  type        = bool
  default     = true
}

variable "default_node_pool_enable_host_encryption" {
  description = "(Optional) Whether host encryption is enabled for the default node pool."
  type        = bool
  default     = false
}

variable "default_node_pool_enable_node_public_ip" {
  description = "(Optional) Whether public IP addresses are enabled for nodes in the default node pool."
  type        = bool
  default     = false
}

variable "default_node_pool_max_pods" {
  description = "(Optional) The maximum number of pods per node in the default node pool."
  type        = number
  default     = 50

  validation {
    condition     = var.default_node_pool_max_pods >= 1 && var.default_node_pool_max_pods <= 250
    error_message = "default_node_pool_max_pods must be between 1 and 250."
  }
}

variable "system_node_pool_node_labels" {
  description = "(Optional) A map of Kubernetes labels to apply to nodes in the default node pool."
  type        = map(string)
  default     = {}
}

variable "system_node_pool_node_taints" {
  description = "(Optional) A list of Kubernetes taints to apply to nodes in the default node pool."
  type        = list(string)
  default     = ["CriticalAddonsOnly=true:NoSchedule"]
}

variable "default_node_pool_os_disk_type" {
  description = "(Optional) The OS disk type for the default node pool. Allowed values: 'Ephemeral', 'Managed'."
  type        = string
  default     = "Ephemeral"

  validation {
    condition     = contains(["Ephemeral", "Managed"], var.default_node_pool_os_disk_type)
    error_message = "Allowed values for default_node_pool_os_disk_type are 'Ephemeral' or 'Managed'."
  }
}

variable "default_node_pool_min_count" {
  description = "(Required) The minimum number of nodes in the default node pool (0-1000)."
  type        = number
  default     = 3

  validation {
    condition     = var.default_node_pool_min_count >= 0 && var.default_node_pool_min_count <= 1000
    error_message = "default_node_pool_min_count must be between 0 and 1000."
  }
}

variable "default_node_pool_max_count" {
  description = "(Required) The maximum number of nodes in the default node pool (0-1000)."
  type        = number
  default     = 10

  validation {
    condition     = var.default_node_pool_max_count >= var.default_node_pool_min_count && var.default_node_pool_max_count >= 0 && var.default_node_pool_max_count <= 1000
    error_message = "default_node_pool_max_count must be between 0 and 1000, and >= min_count."
  }
}

variable "default_node_pool_node_count" {
  description = "(Optional) The initial number of nodes in the default node pool."
  type        = number
  default     = 3

  validation {
    condition     = var.default_node_pool_node_count >= var.default_node_pool_min_count && var.default_node_pool_node_count <= var.default_node_pool_max_count
    error_message = "default_node_pool_node_count must be between min_count and max_count."
  }
}

# AKS Additional Node Pool Variables
variable "additional_node_pool_name" {
  description = "(Required) The name of the additional node pool."
  type        = string
  default     = "user"
}

variable "additional_node_pool_vm_size" {
  description = "(Required) The VM size for nodes in the additional node pool."
  type        = string
  default     = "Standard_F8s_v2"
}

variable "additional_node_pool_availability_zones" {
  description = "(Optional) The availability zones for the additional node pool."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "additional_node_pool_enable_auto_scaling" {
  description = "(Optional) Whether auto-scaling is enabled for the additional node pool."
  type        = bool
  default     = true
}

variable "additional_node_pool_enable_host_encryption" {
  description = "(Optional) Whether host encryption is enabled for the additional node pool."
  type        = bool
  default     = true
}

variable "additional_node_pool_enable_node_public_ip" {
  description = "(Optional) Whether public IP addresses are enabled for nodes in the additional node pool."
  type        = bool
  default     = false
}

variable "additional_node_pool_max_pods" {
  description = "(Optional) The maximum number of pods per node in the additional node pool."
  type        = number
  default     = 50

  validation {
    condition     = var.additional_node_pool_max_pods >= 1 && var.additional_node_pool_max_pods <= 250
    error_message = "additional_node_pool_max_pods must be between 1 and 250."
  }
}

variable "additional_node_pool_mode" {
  description = "(Optional) The mode for the additional node pool. Allowed values: 'System', 'User'."
  type        = string
  default     = "User"

  validation {
    condition     = contains(["System", "User"], var.additional_node_pool_mode)
    error_message = "Allowed values for additional_node_pool_mode are 'System' or 'User'."
  }
}

variable "additional_node_pool_node_labels" {
  description = "(Optional) A map of Kubernetes labels to apply to nodes in the additional node pool."
  type        = map(string)
  default     = {}
}

variable "additional_node_pool_node_taints" {
  description = "(Optional) A list of Kubernetes taints to apply to nodes in the additional node pool."
  type        = list(string)
  default     = []
}

variable "additional_node_pool_os_disk_type" {
  description = "(Optional) The OS disk type for the additional node pool. Allowed values: 'Ephemeral', 'Managed'."
  type        = string
  default     = "Ephemeral"

  validation {
    condition     = contains(["Ephemeral", "Managed"], var.additional_node_pool_os_disk_type)
    error_message = "Allowed values for additional_node_pool_os_disk_type are 'Ephemeral' or 'Managed'."
  }
}

variable "additional_node_pool_os_type" {
  description = "(Optional) The OS type for the additional node pool. Allowed values: 'Linux', 'Windows'."
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows"], var.additional_node_pool_os_type)
    error_message = "Allowed values for additional_node_pool_os_type are 'Linux' or 'Windows'."
  }
}

variable "additional_node_pool_priority" {
  description = "(Optional) The priority for VMs in the additional node pool. Allowed values: 'Regular', 'Spot'."
  type        = string
  default     = "Regular"

  validation {
    condition     = contains(["Regular", "Spot"], var.additional_node_pool_priority)
    error_message = "Allowed values for additional_node_pool_priority are 'Regular' or 'Spot'."
  }
}

variable "additional_node_pool_min_count" {
  description = "(Required) The minimum number of nodes in the additional node pool (0-1000)."
  type        = number
  default     = 3

  validation {
    condition     = var.additional_node_pool_min_count >= 0 && var.additional_node_pool_min_count <= 1000
    error_message = "additional_node_pool_min_count must be between 0 and 1000."
  }
}

variable "additional_node_pool_max_count" {
  description = "(Required) The maximum number of nodes in the additional node pool (0-1000)."
  type        = number
  default     = 10

  validation {
    condition     = var.additional_node_pool_max_count >= var.additional_node_pool_min_count && var.additional_node_pool_max_count >= 0 && var.additional_node_pool_max_count <= 1000
    error_message = "additional_node_pool_max_count must be between 0 and 1000, and >= min_count."
  }
}

variable "additional_node_pool_node_count" {
  description = "(Optional) The initial number of nodes in the additional node pool."
  type        = number
  default     = 3

  validation {
    condition     = var.additional_node_pool_node_count >= var.additional_node_pool_min_count && var.additional_node_pool_node_count <= var.additional_node_pool_max_count
    error_message = "additional_node_pool_node_count must be between min_count and max_count."
  }
}

# AKS Runner Node Pool Variables
variable "runner_node_pool_name" {
  description = "(Required) The name of the runner node pool for CI/CD runners."
  type        = string
  default     = "runners"
}

variable "runner_node_pool_vm_size" {
  description = "(Required) The VM size for nodes in the runner node pool."
  type        = string
  default     = "Standard_F8s_v2"
}

variable "runner_node_pool_availability_zones" {
  description = "(Optional) The availability zones for the runner node pool."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "runner_node_pool_enable_auto_scaling" {
  description = "(Optional) Whether auto-scaling is enabled for the runner node pool."
  type        = bool
  default     = true
}

variable "runner_node_pool_enable_host_encryption" {
  description = "(Optional) Whether host encryption is enabled for the runner node pool."
  type        = bool
  default     = false
}

variable "runner_node_pool_enable_node_public_ip" {
  description = "(Optional) Whether public IP addresses are enabled for nodes in the runner node pool."
  type        = bool
  default     = false
}

variable "runner_node_pool_max_pods" {
  description = "(Optional) The maximum number of pods per node in the runner node pool."
  type        = number
  default     = 50

  validation {
    condition     = var.runner_node_pool_max_pods >= 1 && var.runner_node_pool_max_pods <= 250
    error_message = "runner_node_pool_max_pods must be between 1 and 250."
  }
}

variable "runner_node_pool_mode" {
  description = "(Optional) The mode for the runner node pool. Allowed values: 'System', 'User'."
  type        = string
  default     = "User"

  validation {
    condition     = contains(["System", "User"], var.runner_node_pool_mode)
    error_message = "Allowed values for runner_node_pool_mode are 'System' or 'User'."
  }
}

variable "runner_node_pool_node_labels" {
  description = "(Optional) A map of Kubernetes labels to apply to nodes in the runner node pool."
  type        = map(string)
  default = {
    "purpose" = "ci-cd-runners"
  }
}

variable "runner_node_pool_node_taints" {
  description = "(Optional) A list of Kubernetes taints to apply to nodes in the runner node pool."
  type        = list(string)
  default     = ["ci-cd-runners=true:NoSchedule"]
}

variable "runner_node_pool_os_disk_type" {
  description = "(Optional) The OS disk type for the runner node pool. Allowed values: 'Ephemeral', 'Managed'."
  type        = string
  default     = "Ephemeral"

  validation {
    condition     = contains(["Ephemeral", "Managed"], var.runner_node_pool_os_disk_type)
    error_message = "Allowed values for runner_node_pool_os_disk_type are 'Ephemeral' or 'Managed'."
  }
}

variable "runner_node_pool_os_type" {
  description = "(Optional) The OS type for the runner node pool. Allowed values: 'Linux', 'Windows'."
  type        = string
  default     = "Linux"

  validation {
    condition     = contains(["Linux", "Windows"], var.runner_node_pool_os_type)
    error_message = "Allowed values for runner_node_pool_os_type are 'Linux' or 'Windows'."
  }
}

variable "runner_node_pool_priority" {
  description = "(Optional) The priority for VMs in the runner node pool. Allowed values: 'Regular', 'Spot'."
  type        = string
  default     = "Spot"

  validation {
    condition     = contains(["Regular", "Spot"], var.runner_node_pool_priority)
    error_message = "Allowed values for runner_node_pool_priority are 'Regular' or 'Spot'."
  }
}

variable "runner_node_pool_eviction_policy" {
  description = "(Optional) The eviction policy for spot VMs in the runner node pool. Allowed values: 'Delete', 'Deallocate'."
  type        = string
  default     = "Delete"

  validation {
    condition     = contains(["Delete", "Deallocate"], var.runner_node_pool_eviction_policy)
    error_message = "Allowed values for runner_node_pool_eviction_policy are 'Delete' or 'Deallocate'."
  }
}

variable "runner_node_pool_spot_max_price" {
  description = "(Optional) The maximum spot price for VMs in the runner node pool (-1 for on-demand price)."
  type        = number
  default     = -1
}

variable "runner_node_pool_min_count" {
  description = "(Required) The minimum number of nodes in the runner node pool (0-1000)."
  type        = number
  default     = 0

  validation {
    condition     = var.runner_node_pool_min_count >= 0 && var.runner_node_pool_min_count <= 1000
    error_message = "runner_node_pool_min_count must be between 0 and 1000."
  }
}

variable "runner_node_pool_max_count" {
  description = "(Required) The maximum number of nodes in the runner node pool (0-1000)."
  type        = number
  default     = 10

  validation {
    condition     = var.runner_node_pool_max_count >= var.runner_node_pool_min_count && var.runner_node_pool_max_count >= 0 && var.runner_node_pool_max_count <= 1000
    error_message = "runner_node_pool_max_count must be between 0 and 1000, and >= min_count."
  }
}

variable "runner_node_pool_node_count" {
  description = "(Optional) The initial number of nodes in the runner node pool."
  type        = number
  default     = 0

  validation {
    condition     = var.runner_node_pool_node_count >= var.runner_node_pool_min_count && var.runner_node_pool_node_count <= var.runner_node_pool_max_count
    error_message = "runner_node_pool_node_count must be between min_count and max_count."
  }
}

# Firewall Variables
variable "firewall_name" {
  description = "(Optional) The name of the Azure Firewall."
  type        = string
  default     = "BaboFirewall"
}

variable "firewall_sku_name" {
  description = "(Required) The SKU name for the Azure Firewall. Allowed values: 'AZFW_Hub', 'AZFW_VNet'."
  type        = string
  default     = "AZFW_VNet"

  validation {
    condition     = contains(["AZFW_Hub", "AZFW_VNet"], var.firewall_sku_name)
    error_message = "Allowed values for firewall_sku_name are 'AZFW_Hub' or 'AZFW_VNet'."
  }
}

variable "firewall_sku_tier" {
  description = "(Required) The SKU tier for the Azure Firewall. Allowed values: 'Premium', 'Standard', 'Basic'."
  type        = string
  default     = "Standard"

  validation {
    condition     = contains(["Premium", "Standard", "Basic"], var.firewall_sku_tier)
    error_message = "Allowed values for firewall_sku_tier are 'Premium', 'Standard', or 'Basic'."
  }
}

variable "firewall_aks_node_subnet_prefixes" {
  description = "(Optional) A list of CIDR blocks for AKS node subnets requiring egress through the firewall."
  type        = list(string)
  default     = ["10.0.0.0/20", "10.0.48.0/20"]
}

variable "firewall_threat_intel_mode" {
  description = "(Optional) The threat intelligence mode for the firewall. Allowed values: 'Off', 'Alert', 'Deny'."
  type        = string
  default     = "Alert"

  validation {
    condition     = contains(["Off", "Alert", "Deny"], var.firewall_threat_intel_mode)
    error_message = "Allowed values for firewall_threat_intel_mode are 'Off', 'Alert', or 'Deny'."
  }
}

variable "firewall_zones" {
  description = "(Optional) The availability zones for the Azure Firewall."
  type        = list(string)
  default     = ["1", "2", "3"]
}

# Bastion Variables
variable "bastion_host_name" {
  description = "(Optional) The name of the bastion host."
  type        = string
  default     = "BaboBastionHost"
}

# ACR Variables
variable "acr_sku" {
  description = "(Optional) The SKU for the Azure Container Registry. Allowed values: 'Basic', 'Standard', 'Premium'."
  type        = string
  default     = "Premium"

  validation {
    condition     = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "Allowed values for acr_sku are 'Basic', 'Standard', or 'Premium'."
  }
}

variable "acr_admin_enabled" {
  description = "(Optional) Whether admin user is enabled for the Azure Container Registry."
  type        = bool
  default     = true
}

variable "acr_georeplication_locations" {
  description = "(Optional) A list of Azure locations for geo-replication in the container registry."
  type        = list(string)
  default     = []
}

# VM Jumpbox Variables
variable "vm_size" {
  description = "(Optional) The VM size for the self-hosted agent virtual machine."
  type        = string
  default     = "Standard_DS1_v2"
}

variable "vm_public_ip" {
  description = "(Optional) Whether to create a public IP for the virtual machine."
  type        = bool
  default     = false
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

# Flux / GitHub Variables
variable "gh_flux_aks_token" {
  description = "(Required) The security token (e.g., GitHub Personal Access Token) for the source control repository. Store in Key Vault for security."
  type        = string
  sensitive   = true

  validation {
    condition     = length(var.gh_flux_aks_token) > 0 && length(var.gh_flux_aks_token) <= 255
    error_message = "gh_flux_aks_token must be between 1 and 255 characters."
  }
}

# Custom Script Variables
variable "script_name" {
  description = "(Required) The name of the custom script for the self-hosted agent."
  type        = string
  default     = "configure-self-hosted-agent.sh"
}
