# variable "subscription_id" {
#   description = "Specifies the subscription id"
#   type        = string
# }

variable "location" {
  description = "(Required) Specifies the location for the resource group and all the resources"
  type        = string
  default     = "switzerlandnorth"
}


variable "admin_username" {
  description = "(Required) Specifies the admin username of the self-hosted agent virtual machine and AKS worker nodes."
  type        = string
  default     = "adminuser"
}

variable "storage_account_kind" {
  description = "(Optional) Specifies the account kind of the storage account"
  default     = "StorageV2"
  type        = string

  validation {
    condition     = contains(["Storage", "StorageV2"], var.storage_account_kind)
    error_message = "The account kind of the storage account is invalid."
  }
}

variable "storage_account_replication_type" {
  description = "(Optional) Specifies the replication type of the storage account"
  default     = "LRS"
  type        = string

  validation {
    condition     = contains(["LRS", "ZRS", "GRS", "GZRS", "RA-GRS", "RA-GZRS"], var.storage_account_replication_type)
    error_message = "The replication type of the storage account is invalid."
  }
}

variable "storage_account_tier" {
  description = "(Optional) Specifies the account tier of the storage account"
  default     = "Standard"
  type        = string

  validation {
    condition     = contains(["Standard", "Premium"], var.storage_account_tier)
    error_message = "The account tier of the storage account is invalid."
  }
}

variable "vm_vnet_address_space" {
  description = "Specifies the address space of the hub virtual virtual network"
  default     = ["10.0.0.0/16"]
  type        = list(string)
}

variable "hub_vnet_address_space" {
  description = "Specifies the address space of the hub virtual virtual network"
  default     = ["10.1.0.0/16"]
  type        = list(string)
}

variable "log_analytics_workspace_name" {
  description = "Specifies the name of the log analytics workspace"
  default     = "TestWorkspace"
  type        = string
}

variable "solution_plan_map" {
  description = "Specifies solutions to deploy to log analytics workspace"
  default = {
    ContainerInsights = {
      publisher = "Microsoft"
      product   = "OMSGallery/ContainerInsights"
    }
  }
  type = map(any)
}

variable "key_vault_name" {
  description = "Specifies the name of the key vault."
  type        = string
  default     = "KeyVault01"
}

variable "key_vault_sku_name" {
  description = "(Required) The Name of the SKU used for this Key Vault. Possible values are standard and premium."
  type        = string
  default     = "standard"

  validation {
    condition     = contains(["standard", "premium"], var.key_vault_sku_name)
    error_message = "The sku name of the key vault is invalid."
  }
}

variable "key_vault_enabled_for_deployment" {
  description = "(Optional) Boolean flag to specify whether Azure Virtual Machines are permitted to retrieve certificates stored as secrets from the key vault. Defaults to false."
  type        = bool
  default     = true
}

variable "key_vault_enabled_for_disk_encryption" {
  description = "(Optional) Boolean flag to specify whether Azure Disk Encryption is permitted to retrieve secrets from the vault and unwrap keys. Defaults to false."
  type        = bool
  default     = true
}

variable "key_vault_enabled_for_template_deployment" {
  description = "(Optional) Boolean flag to specify whether Azure Resource Manager is permitted to retrieve secrets from the key vault. Defaults to false."
  type        = bool
  default     = true
}

variable "key_vault_enable_rbac_authorization" {
  description = "(Optional) Boolean flag to specify whether Azure Key Vault uses Role Based Access Control (RBAC) for authorization of data actions. Defaults to false."
  type        = bool
  default     = true
}

variable "key_vault_purge_protection_enabled" {
  description = "(Optional) Is Purge Protection enabled for this Key Vault? Defaults to false."
  type        = bool
  default     = true
}

variable "key_vault_soft_delete_retention_days" {
  description = "(Optional) The number of days that items should be retained for once soft-deleted. This value can be between 7 and 90 (the default) days."
  type        = number
  default     = 30
}

variable "key_vault_bypass" {
  description = "(Required) Specifies which traffic can bypass the network rules. Possible values are AzureServices and None."
  type        = string
  default     = "AzureServices"

  validation {
    condition     = contains(["AzureServices", "None"], var.key_vault_bypass)
    error_message = "The value of the bypass property of the key vault is invalid."
  }
}

variable "key_vault_default_action" {
  description = "(Required) The Default Action to use when no rules match from ip_rules / virtual_network_subnet_ids. Possible values are Allow and Deny."
  type        = string
  default     = "Allow"

  validation {
    condition     = contains(["Allow", "Deny"], var.key_vault_default_action)
    error_message = "The value of the default action property of the key vault is invalid."
  }
}

variable "management_policy_rules" {
  description = "Specifies the management policy rules for the storage account"
  default = [
    {
      name    = "scritps_container_management_policy"
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

variable "aks_cluster_name" {
  description = "(Required) Specifies the name of the AKS cluster."
  default     = "BaboAks"
  type        = string
}

variable "kubernetes_version" {
  description = "Specifies the AKS Kubernetes version"
  default     = "1.33.2"
  type        = string
}

variable "default_node_pool_vm_size" {
  description = "Specifies the vm size of the default node pool"
  #default     = "Standard_F4s_v2"
  default     = "Standard_F8s_v2"
  type = string
}

variable "default_node_pool_availability_zones" {
  description = "Specifies the availability zones of the default node pool"
  default     = ["1", "2", "3"]
  type        = list(string)
}

variable "network_dns_service_ip" {
  description = "Specifies the DNS service IP"
  default     = "10.2.0.10"
  type        = string
}

variable "network_service_cidr" {
  description = "Specifies the service CIDR"
  default     = "10.2.0.0/24"
  type        = string
}

variable "network_plugin" {
  description = "Specifies the network plugin of the AKS cluster"
  default     = "azure"
  type        = string
}

variable "pod_subnet_name" {
  description = "Specifies the name of the pod subnet."
  default     = "PodSubnet"
  type        = string
}

variable "pod_subnet_address_prefix" {
  description = "Specifies the address prefix of the pod subnet"
  type        = list(string)
  default     = ["10.0.32.0/20"]
}

variable "default_node_pool_name" {
  description = "Specifies the name of the default node pool"
  default     = "system"
  type        = string
}

variable "default_node_pool_subnet_name" {
  description = "Specifies the name of the subnet that hosts the default node pool"
  default     = "SystemSubnet"
  type        = string
}

variable "default_node_pool_subnet_address_prefix" {
  description = "Specifies the address prefix of the subnet that hosts the default node pool"
  default     = ["10.0.0.0/20"]
  type        = list(string)
}

variable "default_node_pool_enable_auto_scaling" {
  description = "(Optional) Whether to enable auto-scaler. Defaults to true."
  type        = bool
  default     = true
}

variable "default_node_pool_enable_host_encryption" {
  description = "(Optional) Should the nodes in this Node Pool have host encryption enabled? Defaults to false."
  type        = bool
  default     = false
}

variable "default_node_pool_enable_node_public_ip" {
  description = "(Optional) Should each node have a Public IP Address? Defaults to false. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "default_node_pool_max_pods" {
  description = "(Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
  type        = number
  default     = 50
}

variable "system_node_pool_node_labels" {
  description = "(Optional) A map of Kubernetes labels which should be applied to nodes in this Node Pool. Changing this forces a new resource to be created."
  type        = map(any)
  default     = {}
}

variable "system_node_pool_node_taints" {
  description = "(Optional) A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g key=value:NoSchedule). Changing this forces a new resource to be created."
  type        = list(string)
  default     = ["CriticalAddonsOnly=true:NoSchedule"]
}

variable "default_node_pool_os_disk_type" {
  description = "(Optional) The type of disk which should be used for the Operating System. Possible values are Ephemeral and Managed. Defaults to Managed. Changing this forces a new resource to be created."
  type        = string
  default     = "Ephemeral"
}

variable "default_node_pool_max_count" {
  description = "(Required) The maximum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be greater than or equal to min_count."
  type        = number
  default     = 10
}

variable "default_node_pool_min_count" {
  description = "(Required) The minimum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be less than or equal to max_count."
  type        = number
  default     = 3
}

variable "default_node_pool_node_count" {
  description = "(Optional) The initial number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be a value in the range min_count - max_count."
  type        = number
  default     = 3
}


variable "additional_node_pool_subnet_address_prefix" {
  description = "Specifies the address prefix of the subnet that hosts the additional node pool"
  type        = list(string)
  default     = ["10.0.16.0/20"]
}

variable "automatic_channel_upgrade" {
  description = "(Optional) The upgrade channel for this Kubernetes Cluster. Possible values are patch, rapid, and stable."
  default     = "stable"
  type        = string

  validation {
    condition     = contains(["patch", "rapid", "stable"], var.automatic_channel_upgrade)
    error_message = "The upgrade mode is invalid."
  }
}

variable "sku_tier" {
  description = "(Optional) The SKU Tier that should be used for this Kubernetes Cluster. Possible values are Free and Paid (which includes the Uptime SLA). Defaults to Free."
  default     = "Free"
  type        = string

  validation {
    condition     = contains(["Free", "Paid"], var.sku_tier)
    error_message = "The sku tier is invalid."
  }
}

variable "role_based_access_control_enabled" {
  description = "(Required) Is Role Based Access Control Enabled? Changing this forces a new resource to be created."
  default     = true
  type        = bool
}

variable "admin_group_object_ids" {
  description = "(Optional) A list of Object IDs of Microsoft Entra ID Groups which should have Admin Role on the Cluster."
  default     = ["6e5de8c1-5a4b-409b-994f-0706e4403b77", "78761057-c58c-44b7-aaa7-ce1639c6c4f5"]
  type        = list(string)
}

variable "azure_rbac_enabled" {
  description = "(Optional) Is Role Based Access Control based on Microsoft Entra ID enabled?"
  default     = true
  type        = bool
}

variable "keda_enabled" {
  description = "(Optional) Specifies whether KEDA Autoscaler can be used for workloads."
  type        = bool
  default     = true
}

variable "vertical_pod_autoscaler_enabled" {
  description = "(Optional) Specifies whether Vertical Pod Autoscaler should be enabled."
  type        = bool
  default     = true
}

variable "workload_identity_enabled" {
  description = "(Optional) Specifies whether Microsoft Entra ID Workload Identity should be enabled for the Cluster. Defaults to false."
  type        = bool
  default     = true
}

variable "oidc_issuer_enabled" {
  description = "(Optional) Enable or Disable the OIDC issuer URL."
  type        = bool
  default     = true
}

variable "open_service_mesh_enabled" {
  description = "(Optional) Is Open Service Mesh enabled? For more details, please visit Open Service Mesh for AKS."
  type        = bool
  default     = true
}

variable "image_cleaner_enabled" {
  description = "(Optional) Specifies whether Image Cleaner is enabled."
  type        = bool
  default     = true
}

variable "azure_policy_enabled" {
  description = "(Optional) Should the Azure Policy Add-On be enabled? For more details please visit Understand Azure Policy for Azure Kubernetes Service"
  type        = bool
  default     = true
}

variable "http_application_routing_enabled" {
  description = "(Optional) Should HTTP Application Routing be enabled?"
  type        = bool
  default     = false
}

variable "workload_name" {
  type        = string
  description = "The name of the application or workload (e.g., 'webapp', 'data-platform')."
  default     = "myaks"
}

variable "environment" {
  type        = string
  description = "The deployment environment name (e.g., 'dev', 'tst', 'prd')."
  default     = "dev"
}


variable "spoke_vnet_subnets" {
  type        = any
  description = "A map of subnets to create in the spoke VNet."
  default = {
    "AksNodes" = {
      address_prefixes = ["10.1.0.0/24"]
    },
    "AksPods" = {
      address_prefixes = ["10.1.1.0/24"]
    }
  }
}

variable "additional_node_pool_subnet_name" {
  description = "Specifies the name of the subnet that hosts the default node pool"
  default     = "UserSubnet"
  type        = string
}


variable "additional_node_pool_name" {
  description = "(Required) Specifies the name of the node pool."
  type        = string
  default     = "user"
}

variable "additional_node_pool_vm_size" {
  description = "(Required) The SKU which should be used for the Virtual Machines used in this Node Pool. Changing this forces a new resource to be created."
  type        = string 
  #default     = "Standard_F4s_v2"
  default     = "Standard_F8s_v2"
}

variable "additional_node_pool_availability_zones" {
  description = "(Optional) A list of Availability Zones where the Nodes in this Node Pool should be created in. Changing this forces a new resource to be created."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "additional_node_pool_enable_auto_scaling" {
  description = "(Optional) Whether to enable auto-scaler. Defaults to false."
  type        = bool
  default     = true
}

variable "additional_node_pool_enable_host_encryption" {
  description = "(Optional) Should the nodes in this Node Pool have host encryption enabled? Defaults to false."
  type        = bool
  default     = false
}

variable "additional_node_pool_enable_node_public_ip" {
  description = "(Optional) Should each node have a Public IP Address? Defaults to false. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "additional_node_pool_max_pods" {
  description = "(Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
  type        = number
  default     = 50
}

variable "additional_node_pool_mode" {
  description = "(Optional) Should this Node Pool be used for System or User resources? Possible values are System and User. Defaults to User."
  type        = string
  default     = "User"
}

variable "additional_node_pool_node_labels" {
  description = "(Optional) A map of Kubernetes labels which should be applied to nodes in this Node Pool. Changing this forces a new resource to be created."
  type        = map(any)
  default     = {}
}

variable "additional_node_pool_node_taints" {
  description = "(Optional) A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g key=value:NoSchedule). Changing this forces a new resource to be created."
  type        = list(string)
  default     = []
}

variable "additional_node_pool_os_disk_type" {
  description = "(Optional) The type of disk which should be used for the Operating System. Possible values are Ephemeral and Managed. Defaults to Managed. Changing this forces a new resource to be created."
  type        = string
  default     = "Ephemeral"
}

variable "additional_node_pool_os_type" {
  description = "(Optional) The Operating System which should be used for this Node Pool. Changing this forces a new resource to be created. Possible values are Linux and Windows. Defaults to Linux."
  type        = string
  default     = "Linux"
}

variable "additional_node_pool_priority" {
  description = "(Optional) The Priority for Virtual Machines within the Virtual Machine Scale Set that powers this Node Pool. Possible values are Regular and Spot. Defaults to Regular. Changing this forces a new resource to be created."
  type        = string
  default     = "Regular"
}

variable "additional_node_pool_max_count" {
  description = "(Required) The maximum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be greater than or equal to min_count."
  type        = number
  default     = 10
}

variable "additional_node_pool_min_count" {
  description = "(Required) The minimum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be less than or equal to max_count."
  type        = number
  default     = 3
}

variable "additional_node_pool_node_count" {
  description = "(Optional) The initial number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be a value in the range min_count - max_count."
  type        = number
  default     = 3
}

variable "hub_firewall_subnet_address_prefix" {
  description = "Specifies the address prefix of the firewall subnet"
  default     = ["10.1.0.0/24"]
  type        = list(string)
}

variable "hub_bastion_subnet_address_prefix" {
  description = "Specifies the address prefix of the firewall subnet"
  default     = ["10.1.1.0/24"]
  type        = list(string)
}

variable "firewall_name" {
  description = "Specifies the name of the Azure Firewall"
  default     = "BaboFirewall"
  type        = string
}

variable "firewall_sku_name" {
  description = "(Required) SKU name of the Firewall. Possible values are AZFW_Hub and AZFW_VNet. Changing this forces a new resource to be created."
  default     = "AZFW_VNet"
  type        = string

  validation {
    condition     = contains(["AZFW_Hub", "AZFW_VNet"], var.firewall_sku_name)
    error_message = "The value of the sku name property of the firewall is invalid."
  }
}

variable "firewall_sku_tier" {
  description = "(Required) SKU tier of the Firewall. Possible values are Premium, Standard, and Basic."
  default     = "Standard"
  type        = string

  validation {
    condition     = contains(["Premium", "Standard", "Basic"], var.firewall_sku_tier)
    error_message = "The value of the sku tier property of the firewall is invalid."
  }
}

variable "firewall_threat_intel_mode" {
  description = "(Optional) The operation mode for threat intelligence-based filtering. Possible values are: Off, Alert, Deny. Defaults to Alert."
  default     = "Alert"
  type        = string

  validation {
    condition     = contains(["Off", "Alert", "Deny"], var.firewall_threat_intel_mode)
    error_message = "The threat intel mode is invalid."
  }
}

variable "firewall_zones" {
  description = "Specifies the availability zones of the Azure Firewall"
  default     = ["1", "2", "3"]
  type        = list(string)
}


variable "runner_node_pool_name" {
  description = "(Required) Specifies the name of the node pool."
  type        = string
  default     = "runners"
}

variable "runner_node_pool_subnet_name" {
  description = "Specifies the name of the subnet that hosts the runner node pool"
  default     = "RunnerSubnet"
  type        = string
}


variable "runner_node_pool_vm_size" {
  description = "(Required) The SKU which should be used for the Virtual Machines used in this Node Pool. Changing this forces a new resource to be created."
  type        = string 
  #default     = "Standard_F4s_v2"
  default     = "Standard_F8s_v2"
}

variable "runner_node_pool_availability_zones" {
  description = "(Optional) A list of Availability Zones where the Nodes in this Node Pool should be created in. Changing this forces a new resource to be created."
  type        = list(string)
  default     = ["1", "2", "3"]
}

variable "runner_node_pool_enable_auto_scaling" {
  description = "(Optional) Whether to enable auto-scaler. Defaults to false."
  type        = bool
  default     = true
}

variable "runner_node_pool_enable_host_encryption" {
  description = "(Optional) Should the nodes in this Node Pool have host encryption enabled? Defaults to false."
  type        = bool
  default     = false
}

variable "runner_node_pool_enable_node_public_ip" {
  description = "(Optional) Should each node have a Public IP Address? Defaults to false. Changing this forces a new resource to be created."
  type        = bool
  default     = false
}

variable "runner_node_pool_max_pods" {
  description = "(Optional) The maximum number of pods that can run on each agent. Changing this forces a new resource to be created."
  type        = number
  default     = 50
}

variable "runner_node_pool_mode" {
  description = "(Optional) Should this Node Pool be used for System or User resources? Possible values are System and User. Defaults to User."
  type        = string
  default     = "User"
}

variable "runner_node_pool_node_labels" {
  description = "(Optional) A map of Kubernetes labels which should be applied to nodes in this Node Pool. Changing this forces a new resource to be created."
  type        = map(any)
  default = {
  "purpose" = "ci-cd-runners"
}
}

variable "runner_node_pool_node_taints" {
  description = "(Optional) A list of Kubernetes taints which should be applied to nodes in the agent pool (e.g key=value:NoSchedule). Changing this forces a new resource to be created."
  type        = list(string)
  default     = ["ci-cd-runners=true:NoSchedule"]
}

variable "runner_node_pool_subnet_address_prefix" {
  description = "Specifies the address prefix of the subnet that hosts the runner node pool."
  type        = list(string)
  default     = ["10.0.48.0/20"]
}

variable "runner_node_pool_os_disk_type" {
  description = "(Optional) The type of disk which should be used for the Operating System. Possible values are Ephemeral and Managed. Defaults to Managed. Changing this forces a new resource to be created."
  type        = string
  default     = "Ephemeral"
}

variable "runner_node_pool_os_type" {
  description = "(Optional) The Operating System which should be used for this Node Pool. Changing this forces a new resource to be created. Possible values are Linux and Windows. Defaults to Linux."
  type        = string
  default     = "Linux"
}

variable "runner_node_pool_priority" {
  description = "(Optional) The Priority for Virtual Machines within the Virtual Machine Scale Set that powers this Node Pool. Possible values are Regular and Spot. Defaults to Regular. Changing this forces a new resource to be created."
  type        = string
  default     = "Spot"
}

variable "runner_node_pool_eviction_policy" {
  description = ""
  type        = string
  default     = "Delete"
}

variable "runner_node_pool_spot_max_price" {
  description = ""
  type        = string
  default     = -1
}

variable "runner_node_pool_max_count" {
  description = "(Required) The maximum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be greater than or equal to min_count."
  type        = number
  default     = 10
}

variable "runner_node_pool_min_count" {
  description = "(Required) The minimum number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be less than or equal to max_count."
  type        = number
  default     = 0
}

variable "runner_node_pool_node_count" {
  description = "(Optional) The initial number of nodes which should exist within this Node Pool. Valid values are between 0 and 1000 and must be a value in the range min_count - max_count."
  type        = number
  default     = 0
}

variable "acr_sku" {
  description = "Specifies the name of the container registry"
  type        = string
  default     = "Premium"

  validation {
    condition = contains(["Basic", "Standard", "Premium"], var.acr_sku)
    error_message = "The container registry sku is invalid."
  }
}

variable "acr_admin_enabled" {
  description = "Specifies whether admin is enabled for the container registry"
  type        = bool
  default     = true
}

variable "acr_georeplication_locations" {
  description = "(Optional) A list of Azure locations where the container registry should be geo-replicated."
  type        = list(string)
  default     = []
}

variable "gh_flux_aks_token" {
  description = "The security token (e.g., Personal Access Token) for accessing the source control repository. Should be sourced from a Key Vault for security."
  type        = string
  sensitive   = true
  validation {
    condition     = length(var.gh_flux_aks_token) <= 255
    error_message = "The security token must be 255 characters or less."
  }
}