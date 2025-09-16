output "management_policy_rules" {
  value       = azurerm_storage_management_policy.mgmt_policy.rule
  description = "The applied storage management policy rules."
}
