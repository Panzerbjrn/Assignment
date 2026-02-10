# Azure AD Module Variables

variable "name_prefix" {
  description = "Prefix for naming resources"
  type        = string
}

variable "instance_id" {
  description = "Instance identifier used in resource naming"
  type        = string
  default     = "01"
}

variable "environment" {
  description = "Environment name used in user principal names"
  type        = string
}

variable "domain_name" {
  description = "Azure AD tenant domain name for user principal names (e.g. yourtenant.onmicrosoft.com)"
  type        = string
}

variable "create_test_users" {
  description = "Whether to create test Azure AD users and add them to the groups"
  type        = bool
  default     = true
}

variable "test_user_password" {
  description = "Default password for test Azure AD users"
  type        = string
  sensitive   = true
  default     = "P@ssw0rd!Chang3M3#2026"
}

