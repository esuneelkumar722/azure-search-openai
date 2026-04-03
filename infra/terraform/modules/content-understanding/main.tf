resource "azurerm_cognitive_account" "this" {
  name                  = var.name
  resource_group_name   = var.resource_group_name
  location              = var.location
  kind                  = "AIServices"
  sku_name              = "S0"
  custom_subdomain_name = var.name
  tags                  = var.tags

  network_acls {
    default_action = "Allow"
    ip_rules       = []
  }

  identity {
    type = "SystemAssigned"
  }
}
