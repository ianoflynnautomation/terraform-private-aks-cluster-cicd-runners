output name {
  description = "Specifies the name of the virtual network"
  value       = azurerm_virtual_network.vnet.name
}

output vnet_id {
  description = "Specifies the resource id of the virtual network"
  value       = azurerm_virtual_network.vnet.id
}

output subnet_ids {
 description = "Contains a list of the the resource id of the subnets"
  value       = { for subnet in azurerm_subnet.subnet : subnet.name => subnet.id }
}

output "subnet_address_prefixes" {
  description = "A map of the subnet names and their address prefixes."
  value       = { for subnet in azurerm_subnet.subnet : subnet.name => subnet.address_prefixes }
}

output "subnets" {
  description = "A map of the full subnet objects, keyed by subnet name."
  value       = azurerm_subnet.subnet
  sensitive   = true
}