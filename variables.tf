variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
  validation {
    condition     = length(var.project_name) >= 3 && length(var.project_name) <= 20
    error_message = "Project name must be between 3 and 20 characters."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod."
  }
}

variable "location" {
  description = "Azure region for resources (must be UK for FSI compliance)"
  type        = string
  default     = "uksouth"
  validation {
    condition     = contains(["uksouth", "ukwest", "uknorth"], var.location)
    error_message = "Location must be uksouth, ukwest, or uknorth for UK data residency compliance."
  }
}

variable "cost_center" {
  description = "Cost center for billing"
  type        = string
  default     = "Infrastructure"
}

variable "business_unit" {
  description = "Business unit owning the resources"
  type        = string
  default     = "Technology"
}

variable "criticality" {
  description = "Criticality level of the workload"
  type        = string
  default     = "High"
  validation {
    condition     = contains(["Low", "Medium", "High", "Critical"], var.criticality)
    error_message = "Criticality must be Low, Medium, High, or Critical."
  }
}

variable "tags" {
  description = "Additional tags to apply to all resources"
  type        = map(string)
  default     = {}
}

variable "vnet_address_space" {
  description = "Address space for VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_app_address_prefix" {
  description = "Address prefix for the App Service subnet"
  type        = string
  default     = "10.0.1.0/24"
}

variable "subnet_pe_address_prefix" {
  description = "Address prefix for the Private Endpoint subnet"
  type        = string
  default     = "10.0.2.0/24"
}

variable "subnet_db_address_prefix" {
  description = "Address prefix for the Database subnet"
  type        = string
  default     = "10.0.3.0/24"
}

variable "subnet_db_service_endpoints" {
  description = "Service endpoints for the Database subnet"
  type        = list(string)
  default     = ["Microsoft.Sql", "Microsoft.AzureCosmosDB"]
}

variable "nsg_app_rules" {
  description = "Security rules for the App Service NSG"
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
  default = []
}

variable "nsg_db_rules" {
  description = "Security rules for the Database NSG"
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
  default = []
}

variable "app_service_sku" {
  description = "SKU for App Service Plan"
  type        = string
  default     = "P1v3"
}

variable "app_min_instances" {
  description = "Minimum number of App Service instances"
  type        = number
  default     = 1
}

variable "app_max_instances" {
  description = "Maximum number of App Service instances"
  type        = number
  default     = 3
}

variable "enable_zone_redundancy" {
  description = "Enable zone redundancy for high availability"
  type        = bool
  default     = false
}

variable "enable_autoscaling" {
  description = "Enable autoscaling for App Service Plan"
  type        = bool
  default     = false
}

variable "key_vault_network_action" {
  description = "Default network access action for Key Vault (Allow or Deny)"
  type        = string
  default     = "Deny"
  validation {
    condition     = contains(["Allow", "Deny"], var.key_vault_network_action)
    error_message = "Key Vault network action must be either Allow or Deny."
  }
}

variable "key_vault_allowed_ips" {
  description = "List of allowed IP addresses or CIDR blocks for Key Vault access"
  type        = list(string)
  default     = []
}

variable "sql_sku_name" {
  description = "SKU for SQL Database"
  type        = string
  default     = "GP_Gen5_2"
}

variable "sql_max_size_gb" {
  description = "Maximum size in GB for SQL Database"
  type        = number
  default     = 32
}

variable "sql_backup_retention_days" {
  description = "Backup retention period in days"
  type        = number
  default     = 35
}

variable "sql_geo_backup_enabled" {
  description = "Enable geo-redundant backups"
  type        = bool
  default     = true
}

variable "sql_admin_username" {
  description = "SQL Server administrator username"
  type        = string
  default     = "sqladmin"
  sensitive   = true
}

variable "cosmos_failover_location" {
  description = "Failover location for Cosmos DB"
  type        = string
  default     = "ukwest"
}

variable "cosmos_consistency_level" {
  description = "Consistency level for Cosmos DB"
  type        = string
  default     = "Session"
}

variable "cosmos_max_throughput" {
  description = "Maximum throughput for Cosmos DB autoscale"
  type        = number
  default     = 4000
}

variable "cosmos_backup_interval_minutes" {
  description = "Backup interval in minutes"
  type        = number
  default     = 240
}

variable "cosmos_backup_retention_hours" {
  description = "Backup retention in hours"
  type        = number
  default     = 720
}


# Monitoring Variables
variable "alert_email" {
  description = "Email address for alert notifications"
  type        = string
}

# Azure AD / RBAC Variables (uncomment when AAD is available)
# variable "azure_ad_domain_name" {
#   description = "Azure AD tenant domain"
#   type        = string
# }

# variable "create_test_users" {
#   description = "Whether to create test Azure AD users and add them to the groups"
#   type        = bool
#   default     = true
# }
