# App Service Module

locals {
  name_prefix = var.name_prefix
  instance_id = var.instance_id
}

resource "azurerm_linux_web_app" "app" {
  name                = join("-", [local.name_prefix, local.instance_id, "app"])
  resource_group_name = var.resource_group_name
  location            = var.location
  service_plan_id     = var.service_plan_id
  https_only          = var.https_only
  tags                = var.tags

  identity {
    type = "SystemAssigned"
  }

  site_config {
    always_on                         = var.always_on
    ftps_state                        = "Disabled"
    http2_enabled                     = true
    minimum_tls_version               = "1.2"
    scm_minimum_tls_version           = "1.2"
    vnet_route_all_enabled            = var.app_subnet_id != ""
    health_check_path                 = var.health_check_path
    health_check_eviction_time_in_min = var.health_check_path != null && var.health_check_path != "" ? 2 : null

    dynamic "application_stack" {
      for_each = var.application_stack != null ? [var.application_stack] : []
      content {
        dotnet_version = lookup(application_stack.value, "dotnet_version", null)
        java_version   = lookup(application_stack.value, "java_version", null)
        node_version   = lookup(application_stack.value, "node_version", null)
        python_version = lookup(application_stack.value, "python_version", null)
        php_version    = lookup(application_stack.value, "php_version", null)
        ruby_version   = lookup(application_stack.value, "ruby_version", null)
      }
    }

    dynamic "ip_restriction" {
      for_each = var.app_subnet_id != "" ? [1] : []
      content {
        action                    = "Allow"
        name                      = "AllowVNetTraffic"
        priority                  = 101
        virtual_network_subnet_id = var.app_subnet_id
      }
    }
  }

  app_settings = merge(
    var.app_settings,
    var.app_insights_instrumentation_key != null && var.app_insights_instrumentation_key != "" ? {
      "APPINSIGHTS_INSTRUMENTATIONKEY"             = var.app_insights_instrumentation_key
      "APPLICATIONINSIGHTS_CONNECTION_STRING"      = var.app_insights_connection_string
      "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
    } : {},
    var.app_subnet_id != "" ? {
      "WEBSITE_DNS_SERVER"              = "168.63.129.16"
      "WEBSITE_VNET_ROUTE_ALL"          = "1"
      "WEBSITE_ENABLE_SYNC_UPDATE_SITE" = "true"
    } : {}
  )
}

# VNet Integration
resource "azurerm_app_service_virtual_network_swift_connection" "vnet_integration" {
  count          = var.app_subnet_id != "" ? 1 : 0
  app_service_id = azurerm_linux_web_app.app.id
  subnet_id      = var.app_subnet_id
}
