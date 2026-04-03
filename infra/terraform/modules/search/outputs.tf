output "id" { value = azurerm_search_service.this.id }
output "name" { value = azurerm_search_service.this.name }
output "endpoint" { value = "https://${azurerm_search_service.this.name}.search.windows.net/" }

output "system_identity_principal_id" {
  value = var.sku_name != "free" ? azurerm_search_service.this.identity[0].principal_id : ""
}

output "user_assigned_identity_id" {
  value = var.sku_name != "free" ? azurerm_user_assigned_identity.search[0].id : ""
}

output "user_assigned_identity_client_id" {
  value = var.sku_name != "free" ? azurerm_user_assigned_identity.search[0].client_id : ""
}
