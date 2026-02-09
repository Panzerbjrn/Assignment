# Cosmos DB Module Outputs

output "cosmos_account_id" {
  description = "The ID of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.cosmos.id
}

output "cosmos_account_name" {
  description = "The name of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.cosmos.name
}

output "cosmos_endpoint" {
  description = "The endpoint URL of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.cosmos.endpoint
}

output "cosmos_primary_key" {
  description = "The primary key of the Cosmos DB account"
  value       = azurerm_cosmosdb_account.cosmos.primary_key
  sensitive   = true
}

output "cosmos_primary_sql_connection_string" {
  description = "The primary SQL connection string for the Cosmos DB account"
  value       = azurerm_cosmosdb_account.cosmos.primary_sql_connection_string
  sensitive   = true
}

output "cosmos_secondary_sql_connection_string" {
  description = "The secondary SQL connection string for the Cosmos DB account"
  value       = azurerm_cosmosdb_account.cosmos.secondary_sql_connection_string
  sensitive   = true
}

output "cosmos_primary_readonly_sql_connection_string" {
  description = "The primary read-only SQL connection string for the Cosmos DB account"
  value       = azurerm_cosmosdb_account.cosmos.primary_readonly_sql_connection_string
  sensitive   = true
}

output "cosmos_secondary_readonly_sql_connection_string" {
  description = "The secondary read-only SQL connection string for the Cosmos DB account"
  value       = azurerm_cosmosdb_account.cosmos.secondary_readonly_sql_connection_string
  sensitive   = true
}

output "cosmos_identity_principal_id" {
  description = "The principal ID of the Cosmos DB managed identity"
  value       = azurerm_cosmosdb_account.cosmos.identity[0].principal_id
}

output "database_name" {
  description = "The name of the Cosmos DB SQL database"
  value       = azurerm_cosmosdb_sql_database.db.name
}

output "container_name" {
  description = "The name of the Cosmos DB SQL container"
  value       = azurerm_cosmosdb_sql_container.container.name
}

output "private_endpoint_ip" {
  description = "The private IP address of the Cosmos DB private endpoint"
  value       = azurerm_private_endpoint.cosmos_pe.private_service_connection[0].private_ip_address
}
