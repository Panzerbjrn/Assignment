output "resource_group_name" {
  description = "Name of the resource group"
  value       = module.resource_group.name
}

output "resource_group_location" {
  description = "Location of the resource group"
  value       = module.resource_group.location
}

output "vnet_id" {
  description = "ID of the virtual network"
  value       = module.vnet.vnet_id
}

output "vnet_name" {
  description = "Name of the virtual network"
  value       = module.vnet.vnet_name
}

output "key_vault_name" {
  description = "Name of the Key Vault"
  value       = module.key_vault.key_vault_name
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = module.key_vault.key_vault_uri
}

output "service_plan_name" {
  description = "Name of the App Service Plan"
  value       = module.service_plan.service_plan_name
}

output "app_service_name" {
  description = "Name of the App Service"
  value       = module.app_service.app_service_name
}

output "app_service_url" {
  description = "URL of the App Service"
  value       = "https://${module.app_service.app_service_default_hostname}"
}

output "app_insights_connection_string" {
  description = "Application Insights connection string"
  value       = module.logging.app_insights_connection_string
  sensitive   = true
}

output "sql_server_name" {
  description = "Name of the SQL Server"
  value       = module.sql_database.sql_server_name
}

output "sql_server_fqdn" {
  description = "FQDN of the SQL Server (private endpoint)"
  value       = module.sql_database.sql_server_fqdn
}

output "sql_database_name" {
  description = "Name of the SQL Database"
  value       = module.sql_database.sql_database_name
}

output "cosmos_account_name" {
  description = "Name of the Cosmos DB account"
  value       = module.cosmos_db.cosmos_account_name
}

output "cosmos_endpoint" {
  description = "Endpoint of the Cosmos DB (private endpoint)"
  value       = module.cosmos_db.cosmos_endpoint
}

output "cosmos_database_name" {
  description = "Name of the Cosmos DB database"
  value       = module.cosmos_db.database_name
}

output "cosmos_primary_key" {
  description = "Cosmos DB primary key (store securely)"
  value       = module.cosmos_db.cosmos_primary_key
  sensitive   = true
}

output "log_analytics_workspace_name" {
  description = "Name of the Log Analytics Workspace"
  value       = module.monitoring.log_analytics_workspace_name
}

output "deployment_summary" {
  description = "Deployment summary with key information"
  value = {
    environment        = var.environment
    location           = var.location
    resource_group     = module.resource_group.name
    key_vault          = module.key_vault.key_vault_name
    service_plan       = module.service_plan.service_plan_name
    app_service        = module.app_service.app_service_name
    sql_server         = module.sql_database.sql_server_name
    cosmos_account     = module.cosmos_db.cosmos_account_name
    compliance_tags    = "PRA-FCA, UK Data Residency"
    network_security   = "Private Endpoints, NSGs, VNet Integration"
    monitoring_enabled = true
    rbac_configured    = false
  }
}
