# Monitoring Module

locals {
  name_prefix = var.name_prefix
  instance_id = var.instance_id
}

# Log Analytics
resource "azurerm_log_analytics_workspace" "law" {
  name                = join("-", [local.name_prefix, local.instance_id, "law"])
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = "PerGB2018"
  retention_in_days   = 90
  tags                = var.tags
}

resource "azurerm_log_analytics_solution" "security" {
  solution_name         = "Security"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.law.id
  workspace_name        = azurerm_log_analytics_workspace.law.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/Security"
  }
}

resource "azurerm_log_analytics_solution" "security_insights" {
  solution_name         = "SecurityInsights"
  location              = var.location
  resource_group_name   = var.resource_group_name
  workspace_resource_id = azurerm_log_analytics_workspace.law.id
  workspace_name        = azurerm_log_analytics_workspace.law.name

  plan {
    publisher = "Microsoft"
    product   = "OMSGallery/SecurityInsights"
  }
}

# Action Group for Alerts
resource "azurerm_monitor_action_group" "alerts" {
  name                = join("-", [local.name_prefix, local.instance_id, "ag"])
  resource_group_name = var.resource_group_name
  short_name          = "alerts"
  tags                = var.tags

  email_receiver {
    name                    = "email-alert"
    email_address           = var.alert_email
    use_common_alert_schema = true
  }
}

# Metric Alerts for Service Plan
resource "azurerm_monitor_metric_alert" "app_service_cpu" {
  count               = var.enable_app_service_alerts ? 1 : 0
  name                = join("-", [local.name_prefix, local.instance_id, "cpu", "ma"])
  resource_group_name = var.resource_group_name
  scopes              = [var.service_plan_id]
  description         = "Alert when CPU usage exceeds threshold"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Web/serverFarms"
    metric_name      = "CpuPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.alerts.id
  }
}

resource "azurerm_monitor_metric_alert" "app_service_memory" {
  count               = var.enable_app_service_alerts ? 1 : 0
  name                = join("-", [local.name_prefix, local.instance_id, "mem", "ma"])
  resource_group_name = var.resource_group_name
  scopes              = [var.service_plan_id]
  description         = "Alert when memory usage exceeds threshold"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Web/serverFarms"
    metric_name      = "MemoryPercentage"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.alerts.id
  }
}

resource "azurerm_monitor_metric_alert" "app_service_http_errors" {
  count               = var.enable_app_service_alerts ? 1 : 0
  name                = join("-", [local.name_prefix, local.instance_id, "http5xx", "ma"])
  resource_group_name = var.resource_group_name
  scopes              = [var.app_service_id]
  description         = "Alert on high HTTP 5xx errors"
  severity            = 1
  frequency           = "PT1M"
  window_size         = "PT5M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Web/sites"
    metric_name      = "Http5xx"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 10
  }

  action {
    action_group_id = azurerm_monitor_action_group.alerts.id
  }
}

# Metric Alerts for SQL Database
resource "azurerm_monitor_metric_alert" "sql_dtu" {
  name                = join("-", [local.name_prefix, local.instance_id, "sqldtu", "ma"])
  resource_group_name = var.resource_group_name
  scopes              = [var.sql_database_id]
  description         = "Alert when DTU usage is high"
  severity            = 2
  frequency           = "PT1M"
  window_size         = "PT5M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "dtu_consumption_percent"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 80
  }

  action {
    action_group_id = azurerm_monitor_action_group.alerts.id
  }
}

resource "azurerm_monitor_metric_alert" "sql_deadlock" {
  name                = join("-", [local.name_prefix, local.instance_id, "sqllock", "ma"])
  resource_group_name = var.resource_group_name
  scopes              = [var.sql_database_id]
  description         = "Alert on database deadlocks"
  severity            = 1
  frequency           = "PT5M"
  window_size         = "PT15M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.Sql/servers/databases"
    metric_name      = "deadlock"
    aggregation      = "Total"
    operator         = "GreaterThan"
    threshold        = 1
  }

  action {
    action_group_id = azurerm_monitor_action_group.alerts.id
  }
}

# Metric Alerts for Cosmos DB
resource "azurerm_monitor_metric_alert" "cosmos_availability" {
  count               = var.enable_cosmos_alerts ? 1 : 0
  name                = join("-", [local.name_prefix, local.instance_id, "cosmosavail", "ma"])
  resource_group_name = var.resource_group_name
  scopes              = [var.cosmos_account_id]
  description         = "Alert when Cosmos DB availability is low"
  severity            = 0
  frequency           = "PT1H"
  window_size         = "PT1H"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.DocumentDB/databaseAccounts"
    metric_name      = "ServiceAvailability"
    aggregation      = "Average"
    operator         = "LessThan"
    threshold        = 99
  }

  action {
    action_group_id = azurerm_monitor_action_group.alerts.id
  }
}

resource "azurerm_monitor_metric_alert" "cosmos_latency" {
  count               = var.enable_cosmos_alerts ? 1 : 0
  name                = join("-", [local.name_prefix, local.instance_id, "cosmoslat", "ma"])
  resource_group_name = var.resource_group_name
  scopes              = [var.cosmos_account_id]
  description         = "Alert on high Cosmos DB latency"
  severity            = 2
  frequency           = "PT5M"
  window_size         = "PT15M"
  tags                = var.tags

  criteria {
    metric_namespace = "Microsoft.DocumentDB/databaseAccounts"
    metric_name      = "ServerSideLatency"
    aggregation      = "Average"
    operator         = "GreaterThan"
    threshold        = 1000
  }

  action {
    action_group_id = azurerm_monitor_action_group.alerts.id
  }
}

# Activity Log Alert for Security Events
resource "azurerm_monitor_activity_log_alert" "security_events" {
  name                = join("-", [local.name_prefix, local.instance_id, "sec", "ala"])
  resource_group_name = var.resource_group_name
  scopes              = ["/subscriptions/${data.azurerm_client_config.current.subscription_id}"]
  description         = "Alert on security-related configuration changes"
  location            = "global"
  tags                = var.tags

  criteria {
    category = "Security"
  }

  action {
    action_group_id = azurerm_monitor_action_group.alerts.id
  }
}

data "azurerm_client_config" "current" {}
