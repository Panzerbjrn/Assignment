# Subnet Module Variables

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "instance_id" {
  description = "Instance identifier used in resource naming"
  type        = string
  default     = "01"
}

variable "subnet_name" {
  description = "Short name for the subnet (e.g. app, pe, db)"
  type        = string
}

variable "resource_group_name" {
  description = "Name of the resource group"
  type        = string
}

variable "virtual_network_name" {
  description = "Name of the Virtual Network"
  type        = string
}

variable "address_prefixes" {
  description = "Address prefixes for the subnet"
  type        = list(string)
}

variable "service_endpoints" {
  description = "List of service endpoints to associate with the subnet"
  type        = list(string)
  default     = []
}

variable "delegation" {
  description = "Delegation configuration for the subnet"
  type = object({
    name         = string
    service_name = string
    actions      = list(string)
  })
  default = null
}

