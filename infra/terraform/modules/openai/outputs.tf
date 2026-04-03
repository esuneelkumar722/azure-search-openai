output "name" { value = azurerm_cognitive_account.this.name }
output "id" { value = azurerm_cognitive_account.this.id }
output "endpoint" { value = azurerm_cognitive_account.this.endpoint }
output "principal_id" { value = azurerm_cognitive_account.this.identity[0].principal_id }
