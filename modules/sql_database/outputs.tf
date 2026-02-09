# Azure SQL Database Module Outputs

output "sql_server_id" {
  description = "The ID of the SQL Server"
  value       = azurerm_mssql_server.sql_server.id
}

output "sql_server_name" {
  description = "The name of the SQL Server"
  value       = azurerm_mssql_server.sql_server.name
}

output "sql_server_fqdn" {
  description = "The fully qualified domain name of the SQL Server"
  value       = azurerm_mssql_server.sql_server.fully_qualified_domain_name
}

output "sql_database_id" {
  description = "The ID of the SQL Database"
  value       = azurerm_mssql_database.sql_db.id
}

output "sql_database_name" {
  description = "The name of the SQL Database"
  value       = azurerm_mssql_database.sql_db.name
}

output "sql_server_identity_principal_id" {
  description = "The principal ID of the SQL Server managed identity"
  value       = azurerm_mssql_server.sql_server.identity[0].principal_id
}

output "private_endpoint_ip" {
  description = "The private IP address of the SQL Server private endpoint"
  value       = azurerm_private_endpoint.sql_pe.private_service_connection[0].private_ip_address
}
