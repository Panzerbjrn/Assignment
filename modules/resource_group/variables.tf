# Resource Group Module Variables

variable "name_prefix" {
  description = "Prefix for naming the resource group"
  type        = string
}

variable "instance_id" {
  description = "Instance identifier used in resource naming"
  type        = string
  default     = "01"
}

variable "location" {
  description = "Azure region for resource group (UK South or UK West)"
  type        = string
  default     = "uksouth"

  validation {
    condition     = contains(["uksouth", "ukwest"], var.location)
    error_message = "Location must be uksouth or ukwest for UK data residency compliance."
  }
}

variable "tags" {
  description = "Tags to apply to the resource group"
  type        = map(string)
  default     = {}
}
