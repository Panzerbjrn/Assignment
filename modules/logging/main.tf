# Logging Module - Application Insights and Diagnostic Settings

locals {
  name_prefix = var.name_prefix
  instance_id = var.instance_id
}

# Application Insights
resource "azurerm_application_insights" "app_insights" {
  name                = join("-", [local.name_prefix, local.instance_id, "appi"])
  location            = var.location
  resource_group_name = var.resource_group_name
  application_type    = var.application_type
  retention_in_days   = var.retention_in_days
  tags                = var.tags
}

# Diagnostic Settings for App Service
resource "azurerm_monitor_diagnostic_setting" "app_diagnostics" {
  count                      = var.enable_app_diagnostics ? 1 : 0
  name                       = join("-", [local.name_prefix, local.instance_id, "app", "diag"])
  target_resource_id         = var.app_service_id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AppServiceHTTPLogs"
  }

  enabled_log {
    category = "AppServiceConsoleLogs"
  }

  enabled_log {
    category = "AppServiceAppLogs"
  }

  enabled_log {
    category = "AppServiceAuditLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}
