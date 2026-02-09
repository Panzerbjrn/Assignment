# Network Security Group Module Variables

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "nsg_name" {
  description = "Short name for the NSG (e.g. app, db)"
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

variable "security_rules" {
  description = "List of security rules to apply to the NSG"
  type = list(object({
    name                       = string
    priority                   = number
    direction                  = string
    access                     = string
    protocol                   = string
    source_port_range          = string
    destination_port_range     = string
    source_address_prefix      = string
    destination_address_prefix = string
  }))
}

variable "associate_subnet" {
  description = "Whether to associate this NSG with a subnet"
  type        = bool
  default     = false
}

variable "subnet_id" {
  description = "Subnet ID to associate with. Required when associate_subnet is true."
  type        = string
  default     = ""
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

