# Resource Group Module Variables

variable "name" {
  description = "Name of the resource group"
  type        = string
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

