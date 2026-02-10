# App Service Module Variables

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

variable "service_plan_id" {
  description = "ID of the App Service Plan to use"
  type        = string
}

variable "app_subnet_id" {
  description = "Subnet ID for VNet integration. Set to empty string to disable VNet integration."
  type        = string
  default     = ""
}

variable "enable_vnet_integration" {
  description = "Whether to enable VNet integration. Use this instead of relying on app_subnet_id for count/for_each, since subnet IDs may be unknown at plan time."
  type        = bool
  default     = false
}

variable "https_only" {
  description = "Require HTTPS for app service"
  type        = bool
  default     = true
}

variable "always_on" {
  description = "Keep the app always loaded"
  type        = bool
}

variable "health_check_path" {
  description = "Path for health check endpoint"
  type        = string
  default     = null
}

variable "application_stack" {
  description = "Application stack configuration"
  type = object({
    dotnet_version = optional(string)
    java_version   = optional(string)
    node_version   = optional(string)
    python_version = optional(string)
    php_version    = optional(string)
    ruby_version   = optional(string)
  })
  default = null
}

variable "app_settings" {
  description = "Application settings for the web app"
  type        = map(string)
  default     = {}
}

variable "app_insights_instrumentation_key" {
  description = "Application Insights instrumentation key"
  type        = string
  default     = null
  sensitive   = true
}

variable "app_insights_connection_string" {
  description = "Application Insights connection string"
  type        = string
  default     = null
  sensitive   = true
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}
