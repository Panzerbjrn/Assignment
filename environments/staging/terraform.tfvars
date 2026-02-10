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

# ========================================
# Networking
# ========================================

vnet_address_space = ["10.2.0.0/16"]

# Subnet Configuration
subnet_app_address_prefix   = "10.2.1.0/24"
subnet_pe_address_prefix    = "10.2.2.0/24"
subnet_db_address_prefix    = "10.2.3.0/24"
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
    name                       = "Allow-HTTP-Inbound"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
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
    source_address_prefix      = "10.2.1.0/24" # App subnet
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
    source_address_prefix      = "10.2.1.0/24" # App subnet
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

# ========================================
# App Service - Standard tier for staging
# ========================================

app_service_sku        = "S1"
app_min_instances      = 2
app_max_instances      = 4
enable_zone_redundancy = false

# ========================================
# SQL Database - Production-like tier
# ========================================

sql_sku_name              = "GP_Gen5_2"
sql_max_size_gb           = 32
sql_backup_retention_days = 14
sql_geo_backup_enabled    = true
sql_admin_username        = "sqladmin"

# ========================================
# Cosmos DB - Production-like throughput
# ========================================

cosmos_failover_location       = "ukwest"
cosmos_consistency_level       = "Session"
cosmos_max_throughput          = 4000
cosmos_backup_interval_minutes = 480
cosmos_backup_retention_hours  = 336

# ========================================
# Monitoring
# ========================================

alert_email = "devops-staging@centralindustrial.eu"

# ========================================
# Azure AD / RBAC (uncomment when Azure AD domain is available)
# ========================================

# azure_ad_domain_name = "yourtenant.onmicrosoft.com"
# create_test_users    = true
