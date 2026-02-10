# Resource Group Module

locals {
  name_prefix = var.name_prefix
  instance_id = var.instance_id
}

resource "azurerm_resource_group" "rg" {
  name     = join("-", [local.name_prefix, local.instance_id, "rg"])
  location = var.location
  tags = merge(
    var.tags,
    {
      "ManagedBy"     = "Terraform"
      "DataResidency" = "UK"
      "Compliance"    = "PRA-FCA"
    }
  )
}
