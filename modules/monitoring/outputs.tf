# Monitoring Module Outputs

output "log_analytics_workspace_id" {
  description = "The ID of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.law.id
}

output "log_analytics_workspace_name" {
  description = "The name of the Log Analytics Workspace"
  value       = azurerm_log_analytics_workspace.law.name
}

output "action_group_id" {
  description = "The ID of the Monitor Action Group for alerts"
  value       = azurerm_monitor_action_group.alerts.id
}
