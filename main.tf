# Main Terraform Configuration

# Local variables
locals {
  name_prefix = "${var.project_name}-${var.environment}"

  common_tags = merge(
    var.tags,
    {
      Environment   = var.environment
      ManagedBy     = "Terraform"
      Project       = var.project_name
      Compliance    = "PRA-FCA"
      DataResidency = "UK"
      CostCenter    = var.cost_center
      BusinessUnit  = var.business_unit
      Criticality   = var.criticality
    }
  )
}

# ========================================
# Resource Group
# ========================================

module "resource_group" {
  source      = "./modules/resource_group"
  name_prefix = local.name_prefix
  instance_id = "01"
  location    = var.location
  tags        = local.common_tags
}

# ========================================
# Networking
# ========================================

# Virtual Network
module "vnet" {
  source              = "./modules/vnet"
  name_prefix         = local.name_prefix
  instance_id         = "01"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  vnet_address_space  = var.vnet_address_space
  tags                = local.common_tags

  depends_on = [module.resource_group]
}

# ========================================
# Subnets
# ========================================

# App Service Subnet (with delegation for Web/serverFarms)
module "subnet_app" {
  source               = "./modules/subnet"
  name_prefix          = local.name_prefix
  instance_id          = "01"
  subnet_name          = "app"
  resource_group_name  = module.resource_group.name
  virtual_network_name = module.vnet.vnet_name
  address_prefixes     = [var.subnet_app_address_prefix]

  delegation = {
    name         = "app-service-delegation"
    service_name = "Microsoft.Web/serverFarms"
    actions      = ["Microsoft.Network/virtualNetworks/subnets/action"]
  }

  depends_on = [module.vnet]
}

# Private Endpoint Subnet
module "subnet_pe" {
  source               = "./modules/subnet"
  name_prefix          = local.name_prefix
  instance_id          = "01"
  subnet_name          = "pe"
  resource_group_name  = module.resource_group.name
  virtual_network_name = module.vnet.vnet_name
  address_prefixes     = [var.subnet_pe_address_prefix]

  depends_on = [module.vnet]
}

# Database Subnet
module "subnet_db" {
  source               = "./modules/subnet"
  name_prefix          = local.name_prefix
  instance_id          = "01"
  subnet_name          = "db"
  resource_group_name  = module.resource_group.name
  virtual_network_name = module.vnet.vnet_name
  address_prefixes     = [var.subnet_db_address_prefix]
  service_endpoints    = var.subnet_db_service_endpoints

  depends_on = [module.vnet]
}

# ========================================
# Network Security Groups
# ========================================

# NSG for App Service Subnet
module "nsg_app" {
  source              = "./modules/nsg"
  name_prefix         = local.name_prefix
  instance_id         = "01"
  nsg_name            = "app"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  associate_subnet    = true
  subnet_id           = module.subnet_app.subnet_id
  security_rules      = var.nsg_app_rules
  tags                = local.common_tags

  depends_on = [module.subnet_app]
}

# NSG for Database Subnet
module "nsg_db" {
  source              = "./modules/nsg"
  name_prefix         = local.name_prefix
  instance_id         = "01"
  nsg_name            = "db"
  resource_group_name = module.resource_group.name
  location            = module.resource_group.location
  associate_subnet    = true
  subnet_id           = module.subnet_db.subnet_id
  security_rules      = var.nsg_db_rules
  tags                = local.common_tags

  depends_on = [module.subnet_db]
}

# ========================================
# Private DNS Zones
# ========================================

# SQL Private DNS Zone
module "dns_zone_sql" {
  source              = "./modules/dns_zone"
  name_prefix         = local.name_prefix
  instance_id         = "01"
  resource_group_name = module.resource_group.name
  dns_zone_name       = "privatelink.database.windows.net"
  virtual_network_id  = module.vnet.vnet_id
  link_name           = "sql"
  tags                = local.common_tags

  depends_on = [module.vnet]
}

# Cosmos DB Private DNS Zone
module "dns_zone_cosmos" {
  source              = "./modules/dns_zone"
  name_prefix         = local.name_prefix
  instance_id         = "01"
  resource_group_name = module.resource_group.name
  dns_zone_name       = "privatelink.documents.azure.com"
  virtual_network_id  = module.vnet.vnet_id
  link_name           = "cosmos"
  tags                = local.common_tags

  depends_on = [module.vnet]
}

# Key Vault Private DNS Zone
module "dns_zone_keyvault" {
  source              = "./modules/dns_zone"
  name_prefix         = local.name_prefix
  instance_id         = "01"
  resource_group_name = module.resource_group.name
  dns_zone_name       = "privatelink.vaultcore.azure.net"
  virtual_network_id  = module.vnet.vnet_id
  link_name           = "keyvault"
  tags                = local.common_tags

  depends_on = [module.vnet]
}

# ========================================
# Key Vault
# ========================================

module "key_vault" {
  source                        = "./modules/key_vault"
  name_prefix                   = local.name_prefix
  instance_id                   = "05"
  resource_group_name           = module.resource_group.name
  location                      = module.resource_group.location
  enable_private_endpoint       = true
  private_endpoint_subnet_id    = module.subnet_pe.subnet_id
  keyvault_private_dns_zone_ids = [module.dns_zone_keyvault.dns_zone_id]
  default_network_action        = "Allow"
  allowed_ip_rules              = var.key_vault_allowed_ips
  purge_protection_enabled      = var.environment == "production"
  soft_delete_retention_days    = 90

  # Generate SQL admin password and store in Key Vault
  secrets = {
    sql-admin-password = {
      length           = 32
      special          = true
      override_special = "!#$%&*()-_=+[]{}<>:?"
      content_type     = "SQL Admin Password"
    }
  }

  tags = local.common_tags

  depends_on = [module.vnet, module.subnet_pe, module.dns_zone_keyvault]
}

# ========================================
# Service Plan
# ========================================

module "service_plan" {
  source              = "./modules/service_plan"
  name_prefix         = local.name_prefix
  instance_id         = "01"
  resource_group_name = module.resource_group.name
  location            = "ukwest"
  os_type             = "Linux"
  sku_name            = var.app_service_sku
  enable_autoscaling  = var.enable_autoscaling
  min_instances       = var.app_min_instances
  max_instances       = var.app_max_instances
  tags                = local.common_tags

  depends_on = [module.resource_group]
}

# ========================================
# Logging
# ========================================

module "logging" {
  source                     = "./modules/logging"
  name_prefix                = local.name_prefix
  instance_id                = "01"
  resource_group_name        = module.resource_group.name
  location                   = module.resource_group.location
  application_type           = "web"
  retention_in_days          = 90
  log_analytics_workspace_id = module.monitoring.log_analytics_workspace_id
  tags                       = local.common_tags

  depends_on = [module.resource_group]
}

# ========================================
# App Service
# ========================================

module "app_service" {
  source              = "./modules/app_service"
  name_prefix         = local.name_prefix
  instance_id         = "01"
  resource_group_name = module.resource_group.name
  location            = "ukwest"
  service_plan_id     = module.service_plan.service_plan_id
  always_on           = var.environment == "dev" ? false : true
  health_check_path   = "/health"
  application_stack = {
    node_version = "18-lts"
  }
  app_insights_instrumentation_key = module.logging.app_insights_instrumentation_key
  app_insights_connection_string   = module.logging.app_insights_connection_string
  #  app_subnet_id       = module.subnet_app.subnet_id
  tags = local.common_tags

  depends_on = [module.vnet, module.service_plan]
}

# ========================================
# SQL Database
# ========================================

module "sql_database" {
  source                     = "./modules/sql_database"
  name_prefix                = local.name_prefix
  instance_id                = "01"
  resource_group_name        = module.resource_group.name
  location                   = module.resource_group.location
  private_endpoint_subnet_id = module.subnet_pe.subnet_id
  sql_private_dns_zone_id    = module.dns_zone_sql.dns_zone_id
  sku_name                   = var.sql_sku_name
  max_size_gb                = var.sql_max_size_gb
  zone_redundant             = var.enable_zone_redundancy
  backup_retention_days      = var.sql_backup_retention_days
  geo_backup_enabled         = "true"
  admin_username             = var.sql_admin_username
  admin_password             = module.key_vault.secret_values["sql-admin-password"]
  tags                       = local.common_tags

  depends_on = [module.vnet, module.subnet_pe, module.dns_zone_sql, module.key_vault]
}

# ========================================
# Cosmos DB
# ========================================

module "cosmos_db" {
  source                     = "./modules/cosmos_db"
  name_prefix                = local.name_prefix
  instance_id                = "01"
  resource_group_name        = module.resource_group.name
  location                   = module.resource_group.location
  private_endpoint_subnet_id = module.subnet_pe.subnet_id
  cosmos_private_dns_zone_id = module.dns_zone_cosmos.dns_zone_id
  failover_location          = var.cosmos_failover_location
  consistency_level          = var.cosmos_consistency_level
  max_throughput             = var.cosmos_max_throughput
  backup_interval_minutes    = var.cosmos_backup_interval_minutes
  backup_retention_hours     = var.cosmos_backup_retention_hours
  tags                       = local.common_tags

  depends_on = [module.vnet, module.subnet_pe, module.dns_zone_cosmos]
}

# ========================================
# Monitoring
# ========================================

module "monitoring" {
  source                    = "./modules/monitoring"
  name_prefix               = local.name_prefix
  instance_id               = "01"
  resource_group_name       = module.resource_group.name
  location                  = module.resource_group.location
  enable_app_service_alerts = true
  app_service_id            = module.app_service.app_service_id
  service_plan_id           = module.service_plan.service_plan_id
  sql_database_id           = module.sql_database.sql_database_id
  enable_cosmos_alerts      = true
  cosmos_account_id         = module.cosmos_db.cosmos_account_id
  alert_email               = var.alert_email
  tags                      = local.common_tags

  depends_on = [
    module.app_service,
    module.service_plan,
    module.sql_database,
    module.cosmos_db
  ]
}

# ========================================
# Azure AD - Test Groups and Users (requires Azure AD domain)
# ========================================

# module "azure_ad" {
#   source            = "./modules/azure_ad"
#   name_prefix       = local.name_prefix
#   instance_id       = "01"
#   environment       = var.environment
#   domain_name       = var.azure_ad_domain_name
#   create_test_users = var.create_test_users
# }

# ========================================
# RBAC (requires Azure AD groups)
# ========================================

# module "rbac" {
#   source                            = "./modules/rbac"
#   name_prefix                       = local.name_prefix
#   instance_id                       = "01"
#   resource_group_id                 = module.resource_group.id
#   app_service_id                    = module.app_service.app_service_id
#   sql_server_id                     = module.sql_database.sql_server_id
#   cosmos_account_id                 = module.cosmos_db.cosmos_account_id
#   app_service_identity_principal_id = module.app_service.app_service_identity_principal_id
#   sql_server_identity_principal_id  = module.sql_database.sql_server_identity_principal_id
#   cosmos_identity_principal_id      = module.cosmos_db.cosmos_identity_principal_id
#   developer_group_id                = module.azure_ad.developer_group_id
#   dba_group_id                      = module.azure_ad.dba_group_id
#   operations_group_id               = module.azure_ad.operations_group_id
#   auditor_group_id                  = module.azure_ad.auditor_group_id
#
#   depends_on = [
#     module.resource_group,
#     module.app_service,
#     module.sql_database,
#     module.cosmos_db,
#     module.azure_ad
#   ]
# }
