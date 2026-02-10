# Private DNS Zone Module

locals {
  name_prefix = var.name_prefix
  instance_id = var.instance_id
  link_name   = var.link_name
}

resource "azurerm_private_dns_zone" "this" {
  name                = var.dns_zone_name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  name                  = join("-", [local.name_prefix, local.instance_id, local.link_name, "pdnsz-link"])
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this.name
  virtual_network_id    = var.virtual_network_id
  registration_enabled  = var.registration_enabled
  tags                  = var.tags
}
