output "id" {
  description = "Specifies the resource id of the firewall"
  value       = azurerm_firewall.firewall.id
}

output "name" {
  description = "Specifies the name of the firewall"
  value       = azurerm_firewall.firewall.name
}

output "private_ip_address" {
  description = "The private IP address of the firewall"
  value       = azurerm_firewall.firewall.ip_configuration[0].private_ip_address
}

output "public_ip_address" {
  description = "The public IP address of the firewall"
  value       = azurerm_public_ip.pip.ip_address
}

output "public_ip_id" {
  description = "The ID of the public IP address"
  value       = azurerm_public_ip.pip.id
}

output "firewall_policy_id" {
  description = "The ID of the firewall policy"
  value       = azurerm_firewall_policy.policy.id
}

output "rule_collection_group_ids" {
  description = "Map of rule collection group names to their IDs"
  value       = { for k, v in azurerm_firewall_policy_rule_collection_group.groups : k => v.id }
}