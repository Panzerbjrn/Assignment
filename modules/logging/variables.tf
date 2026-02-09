# Logging Module Variables

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

variable "application_type" {
  description = "Application type for Application Insights"
  type        = string
  default     = "web"
}

variable "retention_in_days" {
  description = "Number of days to retain Application Insights data"
  type        = number
  default     = 90
}

variable "enable_app_diagnostics" {
  description = "Whether to create diagnostic settings for the App Service"
  type        = bool
  default     = false
}

variable "app_service_id" {
  description = "App Service ID for diagnostic settings. Required when enable_app_diagnostics is true."
  type        = string
  default     = ""
}

variable "log_analytics_workspace_id" {
  description = "Log Analytics Workspace ID for diagnostics. Required when enable_app_diagnostics is true."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

