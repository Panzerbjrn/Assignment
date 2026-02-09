# Development Environment Configuration
# UK WSB Azure Infrastructure

project_name = "wsb"
environment  = "dev"
location     = "uksouth"

# Tagging
cost_center   = "WSB-Infrastructure-Dev"
business_unit = "Technology"
criticality   = "Medium"

tags = {
  Owner       = "DevOps Team"
  Purpose     = "Development and Testing"
  Compliance  = "PRA-FCA"
  Environment = "Development"
}

# Networking
vnet_address_space = ["10.1.0.0/16"]

# App Service - Cost-optimized for dev
app_service_sku        = "F1" # Free tier - no quota required (or use "S1" for Standard)
app_min_instances      = 1
app_max_instances      = 1 # Free tier doesn't support scaling
enable_zone_redundancy = false

# SQL Database - Lower tier for dev
sql_sku_name              = "Basic"
sql_max_size_gb           = 2
sql_backup_retention_days = 7
sql_geo_backup_enabled    = false
sql_admin_username        = "sqladmin"

# Cosmos DB - Lower throughput for dev
cosmos_failover_location       = "ukwest"
cosmos_consistency_level       = "Session"
cosmos_max_throughput          = 1000
cosmos_backup_interval_minutes = 1440
cosmos_backup_retention_hours  = 168

# Monitoring
alert_email = "devops-dev@centralindustrial.eu"

# RBAC - Set these to your Azure AD group IDs
# developer_group_id   = "00000000-0000-0000-0000-000000000000"
# dba_group_id         = "00000000-0000-0000-0000-000000000000"
# operations_group_id  = "00000000-0000-0000-0000-000000000000"
# auditor_group_id     = "00000000-0000-0000-0000-000000000000"

