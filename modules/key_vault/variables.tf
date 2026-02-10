# Key Vault Module Variables

variable "name_prefix" {
  description = "Prefix for naming resources (will be truncated if needed for Key Vault name limits)"
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

variable "sku_name" {
  description = "SKU name for Key Vault (standard or premium)"
  type        = string
  default     = "standard"
}

variable "soft_delete_retention_days" {
  description = "Number of days to retain deleted Key Vault items"
  type        = number
  default     = 90
}

variable "purge_protection_enabled" {
  description = "Enable purge protection for Key Vault"
  type        = bool
  default     = true
}

variable "enable_rbac_authorization" {
  description = "Use RBAC for Key Vault authorization instead of access policies"
  type        = bool
  default     = false
}

variable "default_network_action" {
  description = "Default network access action (Allow or Deny)"
  type        = string
  default     = "Deny"
}

variable "allowed_ip_rules" {
  description = "List of allowed IP addresses or CIDR blocks"
  type        = list(string)
  default     = []
}

variable "allowed_subnet_ids" {
  description = "List of allowed subnet IDs"
  type        = list(string)
  default     = []
}

variable "enable_private_endpoint" {
  description = "Whether to create a private endpoint for Key Vault"
  type        = bool
  default     = false
}

variable "private_endpoint_subnet_id" {
  description = "Subnet ID for private endpoint. Required when enable_private_endpoint is true."
  type        = string
  default     = ""
}

variable "keyvault_private_dns_zone_ids" {
  description = "Private DNS zone IDs for Key Vault private endpoint"
  type        = list(string)
  default     = []
}

variable "secrets" {
  description = "Map of secrets to generate and store in Key Vault. Each secret can have 'length', 'special', 'override_special', and 'content_type' attributes."
  type = map(object({
    length           = optional(number)
    special          = optional(bool)
    override_special = optional(string)
    content_type     = optional(string)
  }))
  default = {}
}

variable "static_secrets" {
  description = "Map of static secrets to store in Key Vault. Note: Secret names (keys) are not sensitive, only values are."
  type = map(object({
    value        = string
    content_type = optional(string)
  }))
  default = {}
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

