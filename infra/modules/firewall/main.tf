terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.44.0"
    }
  }
}

resource "azurerm_public_ip" "pip" {
  name                = var.pip_name
  resource_group_name = var.resource_group_name
  location            = var.location
  zones               = var.zones
  allocation_method   = "Static"
  sku                 = "Standard"
  tags                = var.tags

  lifecycle {
    ignore_changes = [
      tags
    ]
  }
}

resource "azurerm_firewall" "firewall" {
  name                = var.name
  resource_group_name = var.resource_group_name
  location            = var.location
  zones               = var.zones
  threat_intel_mode   = var.threat_intel_mode
  sku_name            = var.sku_name
  sku_tier            = var.sku_tier
  firewall_policy_id  = azurerm_firewall_policy.policy.id
  tags                = var.tags


  ip_configuration {
    name                 = "fw_ip_config"
    subnet_id            = var.subnet_id
    public_ip_address_id = azurerm_public_ip.pip.id
  }
}

resource "azurerm_firewall_policy" "policy" {
  name                = "${var.name}Policy"
  resource_group_name = var.resource_group_name
  location            = var.location

  dns {
    proxy_enabled = true
  }

  threat_intelligence_mode = "Deny"
}

resource "azurerm_firewall_policy_rule_collection_group" "policy" {
  name               = "AksEgressPolicyRuleCollectionGroup"
  firewall_policy_id = azurerm_firewall_policy.policy.id
  priority           = 500

  application_rule_collection {
    name     = "AksAndOsDependencies"
    priority = 300
    action   = "Allow"

    rule {
      name             = "AksRequired"
      source_addresses = var.aks_node_subnet_prefixes
      destination_fqdns = [
        "*.cdn.mscr.io",
        "mcr.microsoft.com",
        "*.data.mcr.microsoft.com",
        "management.azure.com",
        "login.microsoftonline.com",
        "acs-mirror.azureedge.net",
        "dc.services.visualstudio.com",
        "*.opinsights.azure.com",
        "*.oms.opinsights.azure.com",
        "*.monitoring.azure.com"
      ]
      protocols {
        type = "Https"
        port = 443
      }
    }

    rule {
      name             = "OsAndContainerRegistries"
      source_addresses = var.aks_node_subnet_prefixes
      destination_fqdns = [
        "download.opensuse.org",
        "security.ubuntu.com",
        "ntp.ubuntu.com",
        "packages.microsoft.com",
        "auth.docker.io",
        "registry-1.docker.io",
        "production.cloudflare.docker.com",
        "registry.k8s.io"
      ]
      protocols {
        type = "Https"
        port = 443
      }
    }
  }

  application_rule_collection {
    name     = "GitHubActionsRunners"
    priority = 200
    action   = "Allow"

    rule {
      name             = "GitHubRunnersRequired"
      source_addresses = var.runner_node_subnet_prefixes

      destination_fqdns = [
        "github.com",
        "api.github.com",
        "codeload.github.com",
        "pkg.actions.githubusercontent.com",
        "*.actions.githubusercontent.com",
        "results-receiver.actions.githubusercontent.com",
        "*.blob.core.windows.net",
        "objects.githubusercontent.com",
        "objects-origin.githubusercontent.com",
        "github-releases.githubusercontent.com",
        "github-registry-files.githubusercontent.com",
        "ghcr.io",
        "*.pkg.github.com",
        "pkg-containers.githubusercontent.com"
      ]
      protocols {
        type = "Https"
        port = 443
      }
    }
  }

  network_rule_collection {
    name     = "NetworkRules"
    priority = 400
    action   = "Allow"

    rule {
      name                  = "TimeAndDns"
      source_addresses      = var.aks_node_subnet_prefixes
      destination_ports     = ["123", "53"]
      destination_addresses = ["*"]
      protocols             = ["UDP"]
    }

  }
}

resource "azurerm_monitor_diagnostic_setting" "settings" {
  name                       = "DiagnosticsSettings"
  target_resource_id         = azurerm_firewall.firewall.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AzureFirewallApplicationRule"
  }

  enabled_log {
    category = "AzureFirewallNetworkRule"
  }

  enabled_log {
    category = "AzureFirewallDnsProxy"
  }

}

resource "azurerm_monitor_diagnostic_setting" "pip_settings" {
  name                       = "DiagnosticsSettings"
  target_resource_id         = azurerm_public_ip.pip.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "DDoSProtectionNotifications"
  }

  enabled_log {
    category = "DDoSMitigationFlowLogs"
  }

  enabled_log {
    category = "DDoSMitigationReports"
  }

}
