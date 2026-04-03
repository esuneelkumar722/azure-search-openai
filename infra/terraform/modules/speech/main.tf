resource "azurerm_cognitive_account" "this" {
  name                  = var.name
  resource_group_name   = var.resource_group_name
  location              = var.location
  kind                  = "SpeechServices"
  sku_name              = var.sku_name
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
