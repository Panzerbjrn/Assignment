# Monitoring Module Variables

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

variable "enable_app_service_alerts" {
  description = "Whether to create App Service metric alerts"
  type        = bool
  default     = false
}

variable "app_service_id" {
  description = "App Service ID for HTTP error alerts. Required when enable_app_service_alerts is true."
  type        = string
  default     = ""
}

variable "service_plan_id" {
  description = "Service Plan ID for CPU/memory alerts. Required when enable_app_service_alerts is true."
  type        = string
  default     = ""
}

variable "sql_database_id" {
  description = "SQL Database ID for monitoring"
  type        = string
  default     = null
}

variable "enable_cosmos_alerts" {
  description = "Whether to create Cosmos DB metric alerts"
  type        = bool
  default     = false
}

variable "cosmos_account_id" {
  description = "Cosmos DB Account ID for monitoring. Required when enable_cosmos_alerts is true."
  type        = string
  default     = ""
}

variable "alert_email" {
  description = "Email address for alert notifications"
  type        = string
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

