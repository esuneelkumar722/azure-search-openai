resource "azurerm_storage_account" "this" {
  name                     = var.name
  resource_group_name      = var.resource_group_name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = replace(var.sku_name, "Standard_", "")
  tags                     = var.tags

  public_network_access_enabled   = var.public_network_access == "Enabled"
  default_to_oauth_authentication = true
  is_hns_enabled                  = var.is_hns_enabled

  # Note: shared_access_key_enabled must stay true for azurerm provider
  # to manage queue/table properties. The app uses managed identity (not keys).
  shared_access_key_enabled = true

  blob_properties {
    delete_retention_policy {
      days = 2
    }
  }

  network_rules {
    default_action = "Allow"
    bypass         = [var.bypass]
  }
}

resource "azurerm_storage_container" "this" {
  for_each = toset(var.containers)

  name                  = each.value
  storage_account_id    = azurerm_storage_account.this.id
  container_access_type = "private"
}
