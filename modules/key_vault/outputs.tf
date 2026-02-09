# Key Vault Module Outputs

output "key_vault_id" {
  description = "The ID of the Key Vault"
  value       = azurerm_key_vault.kv.id
}

output "key_vault_name" {
  description = "The name of the Key Vault"
  value       = azurerm_key_vault.kv.name
}

output "key_vault_uri" {
  description = "The URI of the Key Vault"
  value       = azurerm_key_vault.kv.vault_uri
}

output "secret_ids" {
  description = "Map of secret names to their IDs"
  value = merge(
    { for k, v in azurerm_key_vault_secret.secrets : k => v.id },
    { for k, v in azurerm_key_vault_secret.static_secrets : k => v.id }
  )
}

output "secret_values" {
  description = "Map of secret names to their values (sensitive)"
  value = merge(
    { for k, v in azurerm_key_vault_secret.secrets : k => v.value },
    { for k, v in azurerm_key_vault_secret.static_secrets : k => v.value }
  )
  sensitive = true
}

