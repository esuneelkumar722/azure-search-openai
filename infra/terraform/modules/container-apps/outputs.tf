output "app_name" { value = azurerm_container_app.backend.name }
output "app_uri" { value = "https://${azurerm_container_app.backend.latest_revision_fqdn}" }
output "app_identity_principal_id" { value = data.azurerm_user_assigned_identity.aca.principal_id }

output "environment_id" { value = azurerm_container_app_environment.this.id }
output "environment_name" { value = azurerm_container_app_environment.this.name }

output "registry_name" { value = azurerm_container_registry.this.name }
output "registry_login_server" { value = azurerm_container_registry.this.login_server }
