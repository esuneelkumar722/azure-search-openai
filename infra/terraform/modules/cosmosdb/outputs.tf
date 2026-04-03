output "id" { value = azurerm_cosmosdb_account.this.id }
output "account_name" { value = azurerm_cosmosdb_account.this.name }
output "endpoint" { value = azurerm_cosmosdb_account.this.endpoint }
output "resource_group_name" { value = var.resource_group_name }
