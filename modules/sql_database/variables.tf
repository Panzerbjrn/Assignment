# Azure SQL Database Module Variables

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "instance_id" {
  description = "Instance identifier used in resource naming"
  type        = string
  default     = "01"
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "location" {
  description = "Azure region"
  type        = string
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoint"
  type        = string
}

variable "sql_private_dns_zone_id" {
  description = "Private DNS Zone ID for SQL"
  type        = string
}

variable "sku_name" {
  description = "SKU name for SQL Database"
  type        = string
  default     = "GP_Gen5_2"
}

variable "max_size_gb" {
  description = "Maximum size in GB"
  type        = number
  default     = 32
}

variable "zone_redundant" {
  description = "Enable zone redundancy"
  type        = bool
  default     = false
}

variable "backup_retention_days" {
  description = "Backup retention in days"
  type        = number
  default     = 35
}

variable "geo_backup_enabled" {
  description = "Enable geo-redundant backups"
  type        = bool
  default     = true
}

variable "admin_username" {
  description = "SQL Server admin username"
  type        = string
  default     = "sqladmin"
}

variable "admin_password" {
  description = "SQL Server admin password"
  type        = string
  sensitive   = true
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostics"
  type        = string
  default     = null
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
