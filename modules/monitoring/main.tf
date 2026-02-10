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

# ========================================
# Key Vault Access Anomaly Alerts
# ========================================

# Alert: Failed Key Vault access attempts (potential unauthorized access)
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "kv_failed_access" {
  count               = var.enable_keyvault_alerts ? 1 : 0
  name                = join("-", [local.name_prefix, local.instance_id, "kvfail", "sqr"])
  resource_group_name = var.resource_group_name
  location            = var.location
  description         = "Alert when Key Vault access attempts fail repeatedly (potential unauthorized access)"
  severity            = 1
  enabled             = true
  tags                = var.tags

  scopes                    = [azurerm_log_analytics_workspace.law.id]
  evaluation_frequency      = "PT5M"
  window_duration           = "PT15M"
  target_resource_types     = ["Microsoft.OperationalInsights/workspaces"]
  auto_mitigation_enabled   = true
  workspace_alerts_storage_enabled = false

  criteria {
    query = <<-QUERY
      AzureDiagnostics
      | where ResourceProvider == "MICROSOFT.KEYVAULT"
      | where ResultSignature == "Forbidden" or ResultSignature == "Unauthorized" or httpStatusCode_d >= 400
      | summarize FailedAttempts = count() by CallerIPAddress, OperationName, bin(TimeGenerated, 5m)
      | where FailedAttempts >= 5
    QUERY

    time_aggregation_method = "Count"
    operator                = "GreaterThan"
    threshold               = 0

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.alerts.id]
  }
}

# Alert: Key Vault secret listing (potential enumeration/reconnaissance)
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "kv_secret_enumeration" {
  count               = var.enable_keyvault_alerts ? 1 : 0
  name                = join("-", [local.name_prefix, local.instance_id, "kvenum", "sqr"])
  resource_group_name = var.resource_group_name
  location            = var.location
  description         = "Alert when someone lists all secrets in Key Vault (potential reconnaissance)"
  severity            = 2
  enabled             = true
  tags                = var.tags

  scopes                    = [azurerm_log_analytics_workspace.law.id]
  evaluation_frequency      = "PT5M"
  window_duration           = "PT15M"
  target_resource_types     = ["Microsoft.OperationalInsights/workspaces"]
  auto_mitigation_enabled   = true
  workspace_alerts_storage_enabled = false

  criteria {
    query = <<-QUERY
      AzureDiagnostics
      | where ResourceProvider == "MICROSOFT.KEYVAULT"
      | where OperationName == "SecretList" or OperationName == "KeyList" or OperationName == "CertificateList"
      | summarize ListOperations = count() by CallerIPAddress, identity_claim_upn_s, bin(TimeGenerated, 15m)
      | where ListOperations >= 3
    QUERY

    time_aggregation_method = "Count"
    operator                = "GreaterThan"
    threshold               = 0

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.alerts.id]
  }
}

# Alert: Key Vault access outside business hours (potential compromise)
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "kv_off_hours_access" {
  count               = var.enable_keyvault_alerts ? 1 : 0
  name                = join("-", [local.name_prefix, local.instance_id, "kvooh", "sqr"])
  resource_group_name = var.resource_group_name
  location            = var.location
  description         = "Alert on Key Vault secret access outside business hours (weekdays 07:00-19:00 UTC)"
  severity            = 2
  enabled             = true
  tags                = var.tags

  scopes                    = [azurerm_log_analytics_workspace.law.id]
  evaluation_frequency      = "PT15M"
  window_duration           = "PT30M"
  target_resource_types     = ["Microsoft.OperationalInsights/workspaces"]
  auto_mitigation_enabled   = true
  workspace_alerts_storage_enabled = false

  criteria {
    query = <<-QUERY
      AzureDiagnostics
      | where ResourceProvider == "MICROSOFT.KEYVAULT"
      | where OperationName == "SecretGet" or OperationName == "SecretSet" or OperationName == "SecretDelete"
      | where ResultSignature == "OK" or httpStatusCode_d == 200
      | extend HourOfDay = hourofday(TimeGenerated), DayOfWeek = dayofweek(TimeGenerated)
      | where HourOfDay < 7 or HourOfDay >= 19 or DayOfWeek == 0d or DayOfWeek == 6d
      | summarize OffHoursAccess = count() by CallerIPAddress, OperationName, bin(TimeGenerated, 30m)
    QUERY

    time_aggregation_method = "Count"
    operator                = "GreaterThan"
    threshold               = 0

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.alerts.id]
  }
}

# Alert: Key Vault secrets deleted or purged (potential sabotage)
resource "azurerm_monitor_scheduled_query_rules_alert_v2" "kv_secret_deletion" {
  count               = var.enable_keyvault_alerts ? 1 : 0
  name                = join("-", [local.name_prefix, local.instance_id, "kvdel", "sqr"])
  resource_group_name = var.resource_group_name
  location            = var.location
  description         = "Alert when secrets are deleted or purged from Key Vault"
  severity            = 0
  enabled             = true
  tags                = var.tags

  scopes                    = [azurerm_log_analytics_workspace.law.id]
  evaluation_frequency      = "PT5M"
  window_duration           = "PT5M"
  target_resource_types     = ["Microsoft.OperationalInsights/workspaces"]
  auto_mitigation_enabled   = true
  workspace_alerts_storage_enabled = false

  criteria {
    query = <<-QUERY
      AzureDiagnostics
      | where ResourceProvider == "MICROSOFT.KEYVAULT"
      | where OperationName in ("SecretDelete", "SecretPurge", "KeyDelete", "KeyPurge", "CertificateDelete", "CertificatePurge")
      | project TimeGenerated, OperationName, CallerIPAddress, identity_claim_upn_s, ResultSignature
    QUERY

    time_aggregation_method = "Count"
    operator                = "GreaterThan"
    threshold               = 0

    failing_periods {
      minimum_failing_periods_to_trigger_alert = 1
      number_of_evaluation_periods             = 1
    }
  }

  action {
    action_groups = [azurerm_monitor_action_group.alerts.id]
  }
}

# ========================================
# Deployment Failure Alert
# ========================================

# Activity Log Alert for deployment failures
resource "azurerm_monitor_activity_log_alert" "deployment_failures" {
  name                = join("-", [local.name_prefix, local.instance_id, "deploy", "ala"])
  resource_group_name = var.resource_group_name
  scopes              = ["/subscriptions/${data.azurerm_client_config.current.subscription_id}"]
  description         = "Alert when a resource deployment fails"
  location            = "global"
  tags                = var.tags

  criteria {
    category       = "Administrative"
    operation_name = "Microsoft.Resources/deployments/write"
    status         = "Failed"
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
