resource "azurerm_log_analytics_workspace" "this" {
  name                = var.log_analytics_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_application_insights" "this" {
  name                = var.application_insights_name
  resource_group_name = var.resource_group_name
  location            = var.location
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = "web"
  tags                = var.tags
}

resource "azurerm_portal_dashboard" "this" {
  name                = var.dashboard_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  dashboard_properties = jsonencode({
    lenses = {}
    metadata = {
      model = {
        timeRange = {
          value = { relative = { duration = 24, timeUnit = 1 } }
          type  = "MsPortalFx.Composition.Configuration.ValueTypes.TimeRange"
        }
      }
    }
  })
}
