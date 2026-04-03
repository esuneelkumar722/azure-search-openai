output "vnet_name" { value = azurerm_virtual_network.this.name }
output "vnet_id" { value = azurerm_virtual_network.this.id }
output "backend_subnet_id" { value = azurerm_subnet.backend.id }
output "app_subnet_id" { value = azurerm_subnet.app.id }
output "virtual_network_gateway_id" { value = var.use_vpn_gateway ? azurerm_virtual_network_gateway.this[0].id : "" }
