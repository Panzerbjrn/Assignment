# Staging Environment Configuration
# UK WSB Azure Infrastructure

project_name = "wsb"
environment  = "staging"
location     = "uksouth"

# Tagging
cost_center   = "WSB-Infrastructure-Staging"
business_unit = "Technology"
criticality   = "High"

tags = {
  Owner       = "DevOps Team"
  Purpose     = "Pre-Production Testing"
  Compliance  = "PRA-FCA"
  Environment = "Staging"
}

# Networking
vnet_address_space = ["10.2.0.0/16"]

# App Service - Standard tier for staging
app_service_sku        = "S1"
app_min_instances      = 2
app_max_instances      = 4
enable_zone_redundancy = false

# SQL Database - Production-like tier
sql_sku_name              = "GP_Gen5_2"
sql_max_size_gb           = 32
sql_backup_retention_days = 14
sql_geo_backup_enabled    = true
sql_admin_username        = "sqladmin"

# Cosmos DB - Production-like throughput
cosmos_failover_location       = "ukwest"
cosmos_consistency_level       = "Session"
cosmos_max_throughput          = 4000
cosmos_backup_interval_minutes = 480
cosmos_backup_retention_hours  = 336

# Monitoring
alert_email = "devops-staging@centralindustrial.eu"

# RBAC - Set these to your Azure AD group IDs
# developer_group_id   = "00000000-0000-0000-0000-000000000000"
# dba_group_id         = "00000000-0000-0000-0000-000000000000"
# operations_group_id  = "00000000-0000-0000-0000-000000000000"
# auditor_group_id     = "00000000-0000-0000-0000-000000000000"

