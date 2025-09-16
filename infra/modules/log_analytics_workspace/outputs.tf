output "id" {
  description = "Specifies the log analytics workspace id"
  value = azurerm_log_analytics_workspace.law.id
}

output "workspace_key" {
description = "Specifies the primary shared key of the log analytics workspace"
  value = azurerm_log_analytics_workspace.law.primary_shared_key
}

output "workspace_id" {
  value = azurerm_log_analytics_workspace.law.workspace_id
  description = "Specifies the workspace id of the log analytics workspace"
}

output "name" {
  description = "Specifies the name of the log analytics workspace"
  value = azurerm_log_analytics_workspace.law.name
}

output "primary_shared_key" {
  description = "Specifies the workspace key of the log analytics workspace"
  value = azurerm_log_analytics_workspace.law.primary_shared_key
  sensitive = true
}