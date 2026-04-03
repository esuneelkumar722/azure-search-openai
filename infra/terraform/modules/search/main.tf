# User-assigned identity for search (not created for free tier)
resource "azurerm_user_assigned_identity" "search" {
  count               = var.sku_name != "free" ? 1 : 0
  name                = "${var.name}-identity"
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags
}

resource "azurerm_search_service" "this" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  sku                           = var.sku_name
  tags                          = var.tags
  local_authentication_enabled  = false
  public_network_access_enabled = var.public_network_access == "Enabled"
  semantic_search_sku           = var.semantic_search != "disabled" ? var.semantic_search : null

  partition_count = 1
  replica_count   = 1

  dynamic "identity" {
    for_each = var.sku_name != "free" ? [1] : []
    content {
      type         = "SystemAssigned, UserAssigned"
      identity_ids = [azurerm_user_assigned_identity.search[0].id]
    }
  }
}

# Diagnostic settings
resource "azurerm_monitor_diagnostic_setting" "search" {
  count                      = var.use_application_insights ? 1 : 0
  name                       = "${var.name}-diagnostics"
  target_resource_id         = azurerm_search_service.this.id
  log_analytics_workspace_id = var.log_analytics_workspace_id

  enabled_log {
    category = "OperationLogs"
  }

  enabled_metric {
    category = "AllMetrics"
  }
}

# Shared private link for integrated vectorization
resource "azurerm_search_shared_private_link_service" "storage" {
  count              = length(var.shared_private_link_storage_accounts)
  name               = "search-shared-private-link-${count.index}"
  search_service_id  = azurerm_search_service.this.id
  subresource_name   = "blob"
  target_resource_id = var.shared_private_link_storage_accounts[count.index]
  request_message    = "automatically created by the system"
}
