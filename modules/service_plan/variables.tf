# Service Plan Module Variables

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

variable "os_type" {
  description = "Operating system type (Linux or Windows)"
  type        = string
  default     = "Linux"
}

variable "sku_name" {
  description = "SKU name for App Service Plan"
  type        = string
  default     = "P1v2"
}

variable "enable_autoscaling" {
  description = "Enable autoscaling for the service plan"
  type        = bool
  default     = false
}

variable "min_instances" {
  description = "Minimum number of instances for autoscaling"
  type        = number
  default     = 1
}

variable "max_instances" {
  description = "Maximum number of instances for autoscaling"
  type        = number
  default     = 3
}

variable "scale_up_threshold" {
  description = "CPU percentage threshold to scale up"
  type        = number
  default     = 70
}

variable "scale_down_threshold" {
  description = "CPU percentage threshold to scale down"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

