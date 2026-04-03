resource "azurerm_cosmosdb_account" "this" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  offer_type                    = "Standard"
  kind                          = "GlobalDocumentDB"
  tags                          = var.tags
  public_network_access_enabled = var.public_network_access == "Enabled"
  free_tier_enabled             = var.sku_name == "free"

  dynamic "capabilities" {
    for_each = var.sku_name == "serverless" ? [1] : []
    content {
      name = "EnableServerless"
    }
  }

  consistency_policy {
    consistency_level = "Session"
  }

  geo_location {
    location          = var.location
    failover_priority = 0
    zone_redundant    = false
  }

  ip_range_filter = []
}

resource "azurerm_cosmosdb_sql_database" "this" {
  name                = var.chat_history_database_name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name
  throughput          = var.sku_name == "serverless" ? null : var.throughput
}

resource "azurerm_cosmosdb_sql_container" "this" {
  name                = var.chat_history_container_name
  resource_group_name = var.resource_group_name
  account_name        = azurerm_cosmosdb_account.this.name
  database_name       = azurerm_cosmosdb_sql_database.this.name

  partition_key_kind    = "MultiHash"
  partition_key_paths   = ["/entra_oid", "/session_id"]
  partition_key_version = 2

  indexing_policy {
    indexing_mode = "consistent"

    included_path { path = "/entra_oid/?" }
    included_path { path = "/session_id/?" }
    included_path { path = "/timestamp/?" }
    included_path { path = "/type/?" }

    excluded_path { path = "/*" }
  }
}
