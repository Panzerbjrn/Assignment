# RBAC Module

# App Service to Cosmos DB - Data Contributor
resource "azurerm_role_assignment" "app_to_cosmos" {
  scope                = var.cosmos_account_id
  role_definition_name = "Cosmos DB Account Reader Role"
  principal_id         = var.app_service_identity_principal_id
}

# App Service to SQL Database - SQL DB Contributor
resource "azurerm_role_assignment" "app_to_sql" {
  scope                = var.sql_server_id
  role_definition_name = "SQL DB Contributor"
  principal_id         = var.app_service_identity_principal_id
}

# Developer Group - Contributor on Resource Group
resource "azurerm_role_assignment" "developers" {
  count                = var.developer_group_id != null ? 1 : 0
  scope                = var.resource_group_id
  role_definition_name = "Contributor"
  principal_id         = var.developer_group_id
}

# DBA Group - SQL Security Manager
resource "azurerm_role_assignment" "dba_sql" {
  count                = var.dba_group_id != null ? 1 : 0
  scope                = var.sql_server_id
  role_definition_name = "SQL Security Manager"
  principal_id         = var.dba_group_id
}

# DBA Group - DocumentDB Account Contributor for Cosmos
resource "azurerm_role_assignment" "dba_cosmos" {
  count                = var.dba_group_id != null ? 1 : 0
  scope                = var.cosmos_account_id
  role_definition_name = "DocumentDB Account Contributor"
  principal_id         = var.dba_group_id
}

# Operations Team - Monitoring Contributor
resource "azurerm_role_assignment" "operations" {
  count                = var.operations_group_id != null ? 1 : 0
  scope                = var.resource_group_id
  role_definition_name = "Monitoring Contributor"
  principal_id         = var.operations_group_id
}

# Operations Team - Website Contributor
resource "azurerm_role_assignment" "operations_app" {
  count                = var.operations_group_id != null ? 1 : 0
  scope                = var.app_service_id
  role_definition_name = "Website Contributor"
  principal_id         = var.operations_group_id
}

# Auditor Group - Reader on Resource Group
resource "azurerm_role_assignment" "auditor_reader" {
  count                = var.auditor_group_id != null ? 1 : 0
  scope                = var.resource_group_id
  role_definition_name = "Reader"
  principal_id         = var.auditor_group_id
}

# Auditor Group - Log Analytics Reader
resource "azurerm_role_assignment" "auditor_logs" {
  count                = var.auditor_group_id != null ? 1 : 0
  scope                = var.resource_group_id
  role_definition_name = "Log Analytics Reader"
  principal_id         = var.auditor_group_id
}

# Custom Role for Least Privilege Access
resource "azurerm_role_definition" "app_db_access" {
  name        = "App-Database-Access-Role"
  scope       = var.resource_group_id
  description = "Custom role for application database access with least privilege"

  permissions {
    actions = [
      "Microsoft.Sql/servers/databases/read",
      "Microsoft.DocumentDB/databaseAccounts/readMetadata",
      "Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/*"
    ]
    not_actions = []
    data_actions = [
      "Microsoft.DocumentDB/databaseAccounts/readMetadata",
      "Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/read",
      "Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/create",
      "Microsoft.DocumentDB/databaseAccounts/sqlDatabases/containers/items/upsert"
    ]
  }

  assignable_scopes = [
    var.resource_group_id
  ]
}
