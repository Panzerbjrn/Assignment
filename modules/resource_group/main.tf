# Resource Group Module

resource "azurerm_resource_group" "rg" {
  name     = var.name
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

