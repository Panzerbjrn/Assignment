# Private DNS Zone Module Variables

variable "name_prefix" {
  description = "Prefix for naming the VNet link"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "dns_zone_name" {
  description = "The name of the Private DNS Zone (e.g. privatelink.database.windows.net)"
  type        = string
}

variable "virtual_network_id" {
  description = "ID of the Virtual Network to link to"
  type        = string
}

variable "link_name" {
  description = "Short name for the VNet link (e.g. sql, cosmos, keyvault)"
  type        = string
}

variable "registration_enabled" {
  description = "Enable auto-registration for DNS records"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

