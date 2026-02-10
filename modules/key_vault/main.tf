# Key Vault Module

locals {
  name_prefix = var.name_prefix
  instance_id = var.instance_id
}

data "azurerm_client_config" "current" {}

# Generate password once and store in Key Vault
resource "random_password" "secrets" {
  for_each = var.secrets

  length           = lookup(each.value, "length", 32)
  special          = lookup(each.value, "special", true)
  override_special = lookup(each.value, "override_special", "!#$%&*()-_=+[]{}<>:?")

  # Using keepers here to prevent regeneration on every apply
  keepers = {
    secret_name = each.key
  }
}

# Key Vault
resource "azurerm_key_vault" "kv" {
  name                       = join("-", [local.name_prefix, local.instance_id, "kv"])
  location                   = var.location
  resource_group_name        = var.resource_group_name
  tenant_id                  = data.azurerm_client_config.current.tenant_id
  sku_name                   = var.sku_name
  soft_delete_retention_days = var.soft_delete_retention_days
  purge_protection_enabled   = var.purge_protection_enabled
  rbac_authorization_enabled = var.enable_rbac_authorization

  network_acls {
    default_action             = var.default_network_action
    bypass                     = "AzureServices"
    ip_rules                   = var.allowed_ip_rules
    virtual_network_subnet_ids = var.allowed_subnet_ids
  }

  tags = var.tags
}

# Access Policy for Terraform Service Principal
resource "azurerm_key_vault_access_policy" "terraform" {
  key_vault_id = azurerm_key_vault.kv.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get",
    "List",
    "Set",
    "Delete",
    "Purge",
    "Recover"
  ]
}

# Store generated secrets in Key Vault
resource "azurerm_key_vault_secret" "secrets" {
  for_each = var.secrets

  name         = each.key
  value        = random_password.secrets[each.key].result
  key_vault_id = azurerm_key_vault.kv.id
  content_type = lookup(each.value, "content_type", "password")

  depends_on = [azurerm_key_vault_access_policy.terraform]
}

# Store static secrets in Key Vault
resource "azurerm_key_vault_secret" "static_secrets" {
  for_each = var.static_secrets

  name         = each.key
  value        = each.value.value
  key_vault_id = azurerm_key_vault.kv.id
  content_type = lookup(each.value, "content_type", "text")

  depends_on = [azurerm_key_vault_access_policy.terraform]
}

# Diagnostic Settings - send audit logs to Log Analytics for anomaly detection
resource "azurerm_monitor_diagnostic_setting" "kv_diagnostics" {
  count                      = var.log_analytics_workspace_id != "" ? 1 : 0
  name                       = join("-", [local.name_prefix, local.instance_id, "kv", "diag"])
  target_resource_id         = azurerm_key_vault.kv.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "AuditEvent"
  }

  enabled_log {
    category = "AzurePolicyEvaluationDetails"
  }

  metric {
    category = "AllMetrics"
    enabled  = true
  }
}

# Private Endpoint for Key Vault
resource "azurerm_private_endpoint" "kv" {
  count               = var.enable_private_endpoint ? 1 : 0
  name                = join("-", [local.name_prefix, local.instance_id, "kv", "pe"])
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.private_endpoint_subnet_id

  private_service_connection {
    name                           = join("-", [local.name_prefix, local.instance_id, "kv", "psc"])
    private_connection_resource_id = azurerm_key_vault.kv.id
    is_manual_connection           = false
    subresource_names              = ["vault"]
  }

  dynamic "private_dns_zone_group" {
    for_each = length(var.keyvault_private_dns_zone_ids) > 0 ? [1] : []
    content {
      name                 = "default"
      private_dns_zone_ids = var.keyvault_private_dns_zone_ids
    }
  }

  tags = var.tags
}
