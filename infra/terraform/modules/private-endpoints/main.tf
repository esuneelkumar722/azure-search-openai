# =============================================================================
# Private Endpoints and DNS Zones
# Mirrors infra/private-endpoints.bicep
# =============================================================================

# Flatten the connections into individual endpoints
locals {
  endpoints = flatten([
    for conn in var.private_endpoint_connections : [
      for idx, resource_id in conn.resource_ids : {
        name          = "pe-${var.resource_token}-${conn.group_id}-${idx}"
        group_id      = conn.group_id
        dns_zone_name = conn.dns_zone_name
        resource_id   = resource_id
      }
    ]
  ])

  # Unique DNS zones needed
  dns_zones = distinct([for ep in local.endpoints : ep.dns_zone_name])
}

resource "azurerm_private_dns_zone" "this" {
  for_each = toset(local.dns_zones)

  name                = each.value
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "this" {
  for_each = toset(local.dns_zones)

  name                  = "${replace(each.value, ".", "-")}-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.this[each.value].name
  virtual_network_id    = data.azurerm_virtual_network.this.id
  registration_enabled  = false
  tags                  = var.tags
}

data "azurerm_virtual_network" "this" {
  name                = var.vnet_name
  resource_group_name = var.resource_group_name
}

resource "azurerm_private_endpoint" "this" {
  for_each = { for ep in local.endpoints : ep.name => ep }

  name                = each.value.name
  resource_group_name = var.resource_group_name
  location            = var.location
  subnet_id           = var.vnet_subnet_id
  tags                = var.tags

  private_service_connection {
    name                           = "${each.value.name}-connection"
    private_connection_resource_id = each.value.resource_id
    subresource_names              = [each.value.group_id]
    is_manual_connection           = false
  }

  private_dns_zone_group {
    name                 = "default"
    private_dns_zone_ids = [azurerm_private_dns_zone.this[each.value.dns_zone_name].id]
  }
}
