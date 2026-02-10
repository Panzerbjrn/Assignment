# Virtual Network Module

locals {
  name_prefix = var.name_prefix
  instance_id = var.instance_id
}

resource "azurerm_virtual_network" "vnet" {
  name                = join("-", [local.name_prefix, local.instance_id, "vnet"])
  location            = var.location
  resource_group_name = var.resource_group_name
  address_space       = var.vnet_address_space
  tags                = var.tags
}
