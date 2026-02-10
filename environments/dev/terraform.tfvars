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

# ========================================
# Networking
# ========================================

vnet_address_space = ["10.1.0.0/16"]

# Subnet Configuration
subnet_app_address_prefix   = "10.1.1.0/24"
subnet_pe_address_prefix    = "10.1.2.0/24"
subnet_db_address_prefix    = "10.1.3.0/24"
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
    source_address_prefix      = "10.1.1.0/24" # App subnet
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
    source_address_prefix      = "10.1.1.0/24" # App subnet
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
# App Service - Cost-optimized for dev
# ========================================

app_service_sku        = "F1" # Free tier - no quota required (or use "S1" for Standard)
app_min_instances      = 1
app_max_instances      = 1 # Free tier doesn't support scaling
enable_zone_redundancy = false

# ========================================
# SQL Database - Lower tier for dev
# ========================================

sql_sku_name              = "Basic"
sql_max_size_gb           = 2
sql_backup_retention_days = 7
sql_geo_backup_enabled    = false
sql_admin_username        = "sqladmin"

# ========================================
# Cosmos DB - Lower throughput for dev
# ========================================

cosmos_failover_location       = "ukwest"
cosmos_consistency_level       = "Session"
cosmos_max_throughput          = 1000
cosmos_backup_interval_minutes = 1440
cosmos_backup_retention_hours  = 168

# ========================================
# Monitoring
# ========================================

alert_email = "devops-dev@centralindustrial.eu"

# ========================================
# Azure AD / RBAC (uncomment when Azure AD domain is available)
# ========================================

# azure_ad_domain_name = "yourtenant.onmicrosoft.com"
# create_test_users    = true
