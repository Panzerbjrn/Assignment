# Production Environment Configuration
# UK WSB Azure Infrastructure

project_name = "wsb"
environment  = "prod"
location     = "uksouth"

# Tags
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

# Subnet Configuration
subnet_app_address_prefix   = "10.0.1.0/24"
subnet_pe_address_prefix    = "10.0.2.0/24"
subnet_db_address_prefix    = "10.0.3.0/24"
subnet_db_service_endpoints = ["Microsoft.Sql", "Microsoft.AzureCosmosDB"]

# NSG Rules - App Service
nsg_app_rules = [
  {
    name                       = "Allow-HTTPS-Inbound"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  },
  {
    name                       = "Deny-All-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
]

# NSG Rules - Database
nsg_db_rules = [
  {
    name                       = "Allow-App-Subnet-SQL"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "1433"
    source_address_prefix      = "10.0.1.0/24" # App subnet
    destination_address_prefix = "*"
  },
  {
    name                       = "Allow-App-Subnet-Cosmos"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "10.0.1.0/24" # App subnet
    destination_address_prefix = "*"
  },
  {
    name                       = "Deny-All-Inbound"
    priority                   = 4096
    direction                  = "Inbound"
    access                     = "Deny"
    protocol                   = "*"
    source_port_range          = "*"
    destination_port_range     = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
]


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


# Azure AD / RBAC - commented out as no AD domain currently available for testing.
# azure_ad_domain_name = "CentralIndustrial.eu"
# create_test_users = false  # Production should use real AD groups, not test users
