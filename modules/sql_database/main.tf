# Azure SQL Database Module Variables

# SQL Server
resource "azurerm_mssql_server" "sql_server" {
  name                          = "${var.name_prefix}-sqlserver"
  resource_group_name           = var.resource_group_name
  location                      = var.location
  version                       = "12.0"
  administrator_login           = var.admin_username
  administrator_login_password  = var.admin_password
  minimum_tls_version           = "1.2"
  public_network_access_enabled = false
  tags                          = var.tags

  azuread_administrator {
    login_username = "AzureAD Admin"
    object_id      = data.azurerm_client_config.current.object_id
  }

  identity {
    type = "SystemAssigned"
  }
}

data "azurerm_client_config" "current" {}

# SQL Database
resource "azurerm_mssql_database" "sql_db" {
  name                 = "${var.name_prefix}-sqldb"
  server_id            = azurerm_mssql_server.sql_server.id
  sku_name             = var.sku_name
  max_size_gb          = var.max_size_gb
  zone_redundant       = var.zone_redundant
  geo_backup_enabled   = var.geo_backup_enabled
  storage_account_type = "Geo"
  read_scale           = false
  tags                 = var.tags

  short_term_retention_policy {
    retention_days = var.backup_retention_days
  }

  long_term_retention_policy {
    weekly_retention  = "P4W"
    monthly_retention = "P12M"
    yearly_retention  = "P7Y"
    week_of_year      = 1
  }

  threat_detection_policy {
    state                = "Enabled"
    email_account_admins = "Enabled"
    retention_days       = 90
  }
}

# Transparent Data Encryption (TDE) with customer-managed key (optional)
resource "azurerm_mssql_database_extended_auditing_policy" "sql_audit" {
  database_id            = azurerm_mssql_database.sql_db.id
  log_monitoring_enabled = true
  retention_in_days      = 90
}

# Advanced Data Security
resource "azurerm_mssql_server_security_alert_policy" "sql_security_alert" {
  resource_group_name  = var.resource_group_name
  server_name          = azurerm_mssql_server.sql_server.name
  state                = "Enabled"
  retention_days       = 90
  email_account_admins = true
}

resource "azurerm_mssql_server_vulnerability_assessment" "sql_vulnerability" {
  server_security_alert_policy_id = azurerm_mssql_server_security_alert_policy.sql_security_alert.id
  storage_container_path          = "${azurerm_storage_account.sql_audit_storage.primary_blob_endpoint}${azurerm_storage_container.sql_audit_container.name}/"
  storage_account_access_key      = azurerm_storage_account.sql_audit_storage.primary_access_key

  recurring_scans {
    enabled                   = true
    email_subscription_admins = true
  }
}

# Storage Account for SQL Auditing
resource "azurerm_storage_account" "sql_audit_storage" {
  name                            = replace("${var.name_prefix}sqlaudit", "-", "")
  resource_group_name             = var.resource_group_name
  location                        = var.location
  account_tier                    = "Standard"
  account_replication_type        = "GRS"
  min_tls_version                 = "TLS1_2"
  allow_nested_items_to_be_public = false
  https_traffic_only_enabled      = true
  tags                            = var.tags
}

resource "azurerm_storage_container" "sql_audit_container" {
  name                  = "sqlaudit"
  storage_account_id    = azurerm_storage_account.sql_audit_storage.id
  container_access_type = "private"
}

# Private Endpoint for SQL Server
resource "azurerm_private_endpoint" "sql_pe" {
  name                = "${var.name_prefix}-sql-pe"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${var.name_prefix}-sql-psc"
    private_connection_resource_id = azurerm_mssql_server.sql_server.id
    is_manual_connection           = false
    subresource_names              = ["sqlServer"]
  }

  private_dns_zone_group {
    name                 = "sql-dns-zone-group"
    private_dns_zone_ids = [var.sql_private_dns_zone_id]
  }
}

# Diagnostic Settings
resource "azurerm_monitor_diagnostic_setting" "sql_diagnostics" {
  count                      = var.log_analytics_workspace_id != null ? 1 : 0
  name                       = "${var.name_prefix}-sql-diagnostics"
  target_resource_id         = azurerm_mssql_database.sql_db.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "SQLInsights"
  }

  enabled_log {
    category = "AutomaticTuning"
  }

  enabled_log {
    category = "QueryStoreRuntimeStatistics"
  }

  enabled_log {
    category = "QueryStoreWaitStatistics"
  }

  enabled_log {
    category = "Errors"
  }

  enabled_log {
    category = "DatabaseWaitStatistics"
  }

  enabled_log {
    category = "Timeouts"
  }

  enabled_log {
    category = "Blocks"
  }

  enabled_log {
    category = "Deadlocks"
  }

  enabled_metric {
    category = "AllMetrics"
    #    enabled  = true
  }
}
