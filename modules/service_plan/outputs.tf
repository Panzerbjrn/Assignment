# Service Plan Module Outputs

output "service_plan_id" {
  description = "The ID of the App Service Plan"
  value       = azurerm_service_plan.asp.id
}

output "service_plan_name" {
  description = "The name of the App Service Plan"
  value       = azurerm_service_plan.asp.name
}

