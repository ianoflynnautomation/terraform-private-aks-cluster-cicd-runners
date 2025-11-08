terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.44.0"
    }
  }
}

resource "azurerm_public_ip" "public_ip" {
  count = var.public_ip ? 1 : 0

  name                = coalesce(var.public_ip_name, "${var.name}PublicIp")
  resource_group_name = var.resource_group_name
  location            = var.location
  allocation_method   = "Dynamic"
  domain_name_label   = lower(var.name)
  tags                = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_network_interface" "nic" {
  name                = "${var.name}Nic"
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  ip_configuration {
    name                          = "Configuration"
    subnet_id                     = var.subnet_id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = var.public_ip ? azurerm_public_ip.public_ip[0].id : null
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_network_interface_security_group_association" "nsg_association" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = var.network_security_group_id
}


resource "azurerm_linux_virtual_machine" "vm" {
  name                            = var.name
  resource_group_name             = var.resource_group_name
  location                        = var.location
  size                            = var.size
  computer_name                   = coalesce(var.computer_name, var.name)
  admin_username                  = var.vm_user
  tags                            = var.tags
  disable_password_authentication = true
  custom_data                     = var.custom_data != null ? var.custom_data : null

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  admin_ssh_key {
    username   = var.vm_user
    public_key = var.admin_ssh_public_key
  }

  os_disk {
    name                 = "${var.name}OsDisk"
    caching              = var.os_disk_caching
    storage_account_type = var.os_disk_storage_account_type
    disk_size_gb         = var.os_disk_size_gb
  }

  source_image_reference {
    publisher = var.os_disk_image.publisher
    offer     = var.os_disk_image.offer
    sku       = var.os_disk_image.sku
    version   = var.os_disk_image.version
  }

  boot_diagnostics {
    storage_account_uri = var.boot_diagnostics_storage_account
  }

  identity {
    type         = var.identity_type
    identity_ids = var.identity_type != "SystemAssigned" ? var.identity_ids : null
  }

  lifecycle {
    ignore_changes = [tags]
  }

  depends_on = [azurerm_network_interface_security_group_association.nsg_association]
}

resource "azurerm_virtual_machine_extension" "monitor_agent" {
  count = var.enable_azure_monitor_agent ? 1 : 0

  name                       = "${var.name}AzureMonitorAgent"
  virtual_machine_id         = azurerm_linux_virtual_machine.vm.id
  publisher                  = "Microsoft.Azure.Monitor"
  type                       = "AzureMonitorLinuxAgent"
  type_handler_version       = var.monitor_agent_version
  automatic_upgrade_enabled  = true
  auto_upgrade_minor_version = true
  tags                       = var.tags

  lifecycle {
    ignore_changes = [tags]
  }
}


resource "azurerm_virtual_machine_extension" "dependency_agent" {
  count = var.enable_dependency_agent && var.enable_azure_monitor_agent ? 1 : 0

  name                       = "${var.name}DependencyAgent"
  virtual_machine_id         = azurerm_linux_virtual_machine.vm.id
  publisher                  = "Microsoft.Azure.Monitoring.DependencyAgent"
  type                       = "DependencyAgentLinux"
  type_handler_version       = var.dependency_agent_version
  auto_upgrade_minor_version = true
  automatic_upgrade_enabled  = true
  tags                       = var.tags

  settings = {
    enableAMA = "true"
  }

  lifecycle {
    ignore_changes = [tags]
  }

  depends_on = [azurerm_virtual_machine_extension.monitor_agent]
}


resource "azurerm_monitor_data_collection_rule" "dcr" {
  count = var.enable_data_collection_rule && var.log_analytics_workspace_resource_id != null ? 1 : 0

  name                = coalesce(var.data_collection_rule_name, "dcr-${var.name}")
  resource_group_name = var.resource_group_name
  location            = var.location
  kind                = "Linux"
  tags                = var.tags

  destinations {
    log_analytics {
      workspace_resource_id = var.log_analytics_workspace_resource_id
      name                  = "workspace"
    }
  }

  data_flow {
    streams      = ["Microsoft-InsightsMetrics", "Microsoft-Syslog", "Microsoft-Perf"]
    destinations = ["workspace"]
  }

  data_sources {
    syslog {
      streams        = ["Microsoft-Syslog"]
      facility_names = ["*"]
      log_levels     = ["*"]
      name           = "syslog"
    }

    performance_counter {
      streams                       = ["Microsoft-Perf", "Microsoft-InsightsMetrics"]
      sampling_frequency_in_seconds = 60
      name                          = "perfcounter"
      counter_specifiers = [
        "Processor(*)\\% Processor Time",
        "Processor(*)\\% Idle Time",
        "Processor(*)\\% User Time",
        "Processor(*)\\% Nice Time",
        "Processor(*)\\% Privileged Time",
        "Processor(*)\\% IO Wait Time",
        "Processor(*)\\% Interrupt Time",
        "Memory(*)\\Available MBytes Memory",
        "Memory(*)\\% Available Memory",
        "Memory(*)\\Used Memory MBytes",
        "Memory(*)\\% Used Memory",
        "Memory(*)\\Pages/sec",
        "Memory(*)\\Page Reads/sec",
        "Memory(*)\\Page Writes/sec",
        "Memory(*)\\Available MBytes Swap",
        "Memory(*)\\% Available Swap Space",
        "Memory(*)\\Used MBytes Swap Space",
        "Memory(*)\\% Used Swap Space",
        "Process(*)\\Pct User Time",
        "Process(*)\\Pct Privileged Time",
        "Process(*)\\Used Memory",
        "Process(*)\\Virtual Shared Memory",
        "Logical Disk(*)\\% Free Inodes",
        "Logical Disk(*)\\% Used Inodes",
        "Logical Disk(*)\\Free Megabytes",
        "Logical Disk(*)\\% Free Space",
        "Logical Disk(*)\\% Used Space",
        "Logical Disk(*)\\Logical Disk Bytes/sec",
        "Logical Disk(*)\\Disk Read Bytes/sec",
        "Logical Disk(*)\\Disk Write Bytes/sec",
        "Logical Disk(*)\\Disk Transfers/sec",
        "Logical Disk(*)\\Disk Reads/sec",
        "Logical Disk(*)\\Disk Writes/sec",
        "Network(*)\\Total Bytes Transmitted",
        "Network(*)\\Total Bytes Received",
        "Network(*)\\Total Bytes",
        "Network(*)\\Total Packets Transmitted",
        "Network(*)\\Total Packets Received",
        "Network(*)\\Total Rx Errors",
        "Network(*)\\Total Tx Errors",
        "Network(*)\\Total Collisions",
        "System(*)\\Uptime",
        "System(*)\\Load1",
        "System(*)\\Load5",
        "System(*)\\Load15",
        "System(*)\\Users",
        "System(*)\\Unique Users",
        "System(*)\\CPUs"
      ]
    }
  }

  lifecycle {
    ignore_changes = [tags]
  }
}

resource "azurerm_monitor_data_collection_rule_association" "dcr_association" {
  count = var.enable_data_collection_rule && var.log_analytics_workspace_resource_id != null ? 1 : 0

  name                    = "${var.name}-dcr-association"
  target_resource_id      = azurerm_linux_virtual_machine.vm.id
  data_collection_rule_id = azurerm_monitor_data_collection_rule.dcr[0].id
  description             = "Association between the Data Collection Rule and the Linux VM"
}
