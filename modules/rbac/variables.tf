# RBAC Module Variables

variable "resource_group_id" {
  description = "Resource Group ID for RBAC assignment"
  type        = string
}

variable "app_service_id" {
  description = "App Service ID for RBAC assignment"
  type        = string
}

variable "sql_server_id" {
  description = "SQL Server ID for RBAC assignment"
  type        = string
}

variable "cosmos_account_id" {
  description = "Cosmos DB Account ID for RBAC assignment"
  type        = string
}

variable "app_service_identity_principal_id" {
  description = "App Service managed identity principal ID"
  type        = string
}

variable "sql_server_identity_principal_id" {
  description = "SQL Server managed identity principal ID"
  type        = string
}

variable "cosmos_identity_principal_id" {
  description = "Cosmos DB managed identity principal ID"
  type        = string
}

variable "developer_group_id" {
  description = "Azure AD group ID for developers"
  type        = string
  default     = null
}

variable "dba_group_id" {
  description = "Azure AD group ID for DBAs"
  type        = string
  default     = null
}

variable "operations_group_id" {
  description = "Azure AD group ID for operations team"
  type        = string
  default     = null
}

variable "auditor_group_id" {
  description = "Azure AD group ID for auditors (read-only)"
  type        = string
  default     = null
}

