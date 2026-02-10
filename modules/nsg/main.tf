# Network Security Group Module

locals {
  name_prefix = var.name_prefix
  instance_id = var.instance_id
  nsg_name    = var.nsg_name
}

resource "azurerm_network_security_group" "this" {
  name                = join("-", [local.name_prefix, local.instance_id, local.nsg_name, "nsg"])
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags

  dynamic "security_rule" {
    for_each = var.security_rules
    content {
      name                       = security_rule.value.name
      priority                   = security_rule.value.priority
      direction                  = security_rule.value.direction
      access                     = security_rule.value.access
      protocol                   = security_rule.value.protocol
      source_port_range          = security_rule.value.source_port_range
      destination_port_range     = security_rule.value.destination_port_range
      source_address_prefix      = security_rule.value.source_address_prefix
      destination_address_prefix = security_rule.value.destination_address_prefix
    }
  }
}

# Optionally associate the NSG with a subnet
resource "azurerm_subnet_network_security_group_association" "this" {
  count                     = var.associate_subnet ? 1 : 0
  subnet_id                 = var.subnet_id
  network_security_group_id = azurerm_network_security_group.this.id
}
