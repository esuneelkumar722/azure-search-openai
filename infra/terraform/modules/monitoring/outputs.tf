output "application_insights_name" { value = azurerm_application_insights.this.name }
output "application_insights_id" { value = azurerm_application_insights.this.id }
output "connection_string" { value = azurerm_application_insights.this.connection_string }
output "log_analytics_workspace_name" { value = azurerm_log_analytics_workspace.this.name }
output "log_analytics_workspace_id" { value = azurerm_log_analytics_workspace.this.id }
