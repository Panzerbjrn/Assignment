# RBAC Module Outputs

output "custom_role_id" {
  description = "The ID of the custom RBAC role definition"
  value       = azurerm_role_definition.app_db_access.id
}

output "custom_role_name" {
  description = "The name of the custom RBAC role definition"
  value       = azurerm_role_definition.app_db_access.name
}
