# Production Environment Configuration
# UK WSB Azure Infrastructure

project_name = "wsb"
environment  = "prod"
location     = "uksouth"

# Tagging
cost_center   = "WSB-Infrastructure-Production"
business_unit = "Technology"
criticality   = "Critical"

tags = {
  Owner              = "Platform Team"
  Purpose            = "Production Workload"
  Compliance         = "PRA-FCA"
  Environment        = "Production"
  DataClassification = "Confidential"
}

# Networking
vnet_address_space = ["10.0.0.0/16"]

# App Service - Standard tier for production
app_service_sku        = "S1"
app_min_instances      = 3
app_max_instances      = 10
enable_zone_redundancy = false # S1 doesn't support zone redundancy (would need Premium for that)

# SQL Database - Production tier with high availability
sql_sku_name              = "BC_Gen5_4"
sql_max_size_gb           = 250
sql_backup_retention_days = 35
sql_geo_backup_enabled    = true
sql_admin_username        = "sqladmin"

# Cosmos DB - Production throughput with multi-region
cosmos_failover_location       = "ukwest"
cosmos_consistency_level       = "Session"
cosmos_max_throughput          = 10000
cosmos_backup_interval_minutes = 240
cosmos_backup_retention_hours  = 720

# Monitoring
alert_email = "platform-alerts@centralindustrial.eu"

# RBAC - Set these to your Azure AD group IDs
# developer_group_id   = "00000000-0000-0000-0000-000000000000"
# dba_group_id         = "00000000-0000-0000-0000-000000000000"
# operations_group_id  = "00000000-0000-0000-0000-000000000000"
# auditor_group_id     = "00000000-0000-0000-0000-000000000000"

