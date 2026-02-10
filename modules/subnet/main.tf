# Subnet Module

locals {
  name_prefix = var.name_prefix
  instance_id = var.instance_id
  subnet_name = var.subnet_name
}

resource "azurerm_subnet" "this" {
  name                 = join("-", [local.name_prefix, local.instance_id, local.subnet_name, "snet"])
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.virtual_network_name
  address_prefixes     = var.address_prefixes
  service_endpoints    = var.service_endpoints

  dynamic "delegation" {
    for_each = var.delegation != null ? [var.delegation] : []
    content {
      name = delegation.value.name
      service_delegation {
        name    = delegation.value.service_name
        actions = delegation.value.actions
      }
    }
  }
}
