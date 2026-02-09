# App Service Module Outputs

output "app_service_id" {
  description = "The ID of the App Service"
  value       = azurerm_linux_web_app.app.id
}

output "app_service_name" {
  description = "The name of the App Service"
  value       = azurerm_linux_web_app.app.name
}

output "app_service_default_hostname" {
  description = "The default hostname of the App Service"
  value       = azurerm_linux_web_app.app.default_hostname
}

output "app_service_identity_principal_id" {
  description = "The principal ID of the App Service managed identity"
  value       = azurerm_linux_web_app.app.identity[0].principal_id
}

output "app_service_identity_tenant_id" {
  description = "The tenant ID of the App Service managed identity"
  value       = azurerm_linux_web_app.app.identity[0].tenant_id
}
