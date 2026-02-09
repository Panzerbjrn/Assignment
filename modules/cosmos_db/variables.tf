# Cosmos DB Module Variables

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
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

variable "cosmos_private_dns_zone_id" {
  description = "Private DNS Zone ID for Cosmos DB"
  type        = string
}

variable "failover_location" {
  description = "Failover location for geo-redundancy"
  type        = string
  default     = "ukwest"
}

variable "consistency_level" {
  description = "Consistency level for Cosmos DB"
  type        = string
  default     = "Session"
}

variable "max_throughput" {
  description = "Maximum throughput for autoscale"
  type        = number
  default     = 4000
}

variable "backup_interval_minutes" {
  description = "Backup interval in minutes"
  type        = number
  default     = 240
}

variable "backup_retention_hours" {
  description = "Backup retention in hours"
  type        = number
  default     = 720
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
