output "id" {
  description = "The IDs of the created virtual machines."
  value       = azurerm_linux_virtual_machine.vm-linux.id
  sensitive   = false
}

output "public_ip" {
  description = "Specifies the public IP address of the virtual machine"
  value       = azurerm_linux_virtual_machine.vm-linux.public_ip_address
}

output "identity_principal_id" {
  description = "The Principal ID of the System Assigned Managed Identity. This is required for creating role assignments."
  value       = azurerm_linux_virtual_machine.vm-linux.identity[0].principal_id
}
