# Logging Module Outputs

output "app_insights_id" {
  description = "The ID of Application Insights"
  value       = azurerm_application_insights.app_insights.id
}

output "app_insights_instrumentation_key" {
  description = "The instrumentation key of Application Insights"
  value       = azurerm_application_insights.app_insights.instrumentation_key
  sensitive   = true
}

output "app_insights_connection_string" {
  description = "The connection string of Application Insights"
  value       = azurerm_application_insights.app_insights.connection_string
  sensitive   = true
}
