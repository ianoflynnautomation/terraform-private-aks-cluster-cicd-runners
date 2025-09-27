output "workload_identity_client_id" {
  description = "The Client ID of the User Assigned Identity for the Actions Runner Controller."
  value       = azurerm_user_assigned_identity.actions_runner_controller.client_id
}

output "acr_login_server" {
  value       = module.container_registry.login_server
  description = "ACR login server for runner images."
}

output "key_vault_uri" {
  value       = module.key_vault.vault_uri
  description = "Key Vault URI (extract name via split)."
}

output "oidc_issuer_url" {
  value       = module.aks_cluster.oidc_issuer_url
  description = "OIDC issuer for federation."
}

output "aks_name" {
  value       = local.aks_name
  description = "AKS cluster name."
}

output "rg_name" {
  value       = local.rg_name
  description = "Resource group name."
}