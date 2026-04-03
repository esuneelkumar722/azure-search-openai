# =============================================================================
# Azure Container Registry
# =============================================================================

resource "azurerm_container_registry" "this" {
  name                = var.registry_name
  resource_group_name = var.resource_group_name
  location            = var.location
  sku                 = "Basic"
  admin_enabled       = false
  tags                = var.tags
}

# =============================================================================
# Container Apps Environment
# =============================================================================

resource "azurerm_container_app_environment" "this" {
  name                       = var.environment_name
  resource_group_name        = var.resource_group_name
  location                   = var.location
  log_analytics_workspace_id = var.log_analytics_workspace_id != "" ? var.log_analytics_workspace_id : null
  tags                       = var.tags

  infrastructure_subnet_id       = var.subnet_resource_id != "" ? var.subnet_resource_id : null
  internal_load_balancer_enabled = var.subnet_resource_id != "" ? var.use_private_ingress : null

  dynamic "workload_profile" {
    for_each = var.workload_profile != "Consumption" ? [1] : []
    content {
      name                  = var.workload_profile
      workload_profile_type = var.workload_profile
      minimum_count         = 1
      maximum_count         = 3
    }
  }
}

# =============================================================================
# Container App (Backend)
# =============================================================================

resource "azurerm_container_app" "backend" {
  name                         = var.app_name
  container_app_environment_id = azurerm_container_app_environment.this.id
  resource_group_name          = var.resource_group_name
  revision_mode                = "Single"
  tags                         = merge(var.tags, { "azd-service-name" = "backend" })

  identity {
    type         = "UserAssigned"
    identity_ids = [var.identity_id]
  }

  registry {
    server   = azurerm_container_registry.this.login_server
    identity = var.identity_id
  }

  template {
    min_replicas = var.min_replicas
    max_replicas = 10

    container {
      name   = "main"
      # Use placeholder on first deploy (ACR is empty). CI/CD pipeline updates to real image.
      image  = "mcr.microsoft.com/azuredocs/containerapps-helloworld:latest"
      cpu    = var.cpu
      memory = var.memory

      dynamic "env" {
        for_each = var.env_variables
        content {
          name  = env.key
          value = env.value
        }
      }

      dynamic "env" {
        for_each = var.env_secrets
        content {
          name       = env.value.name
          secret_name = env.value.secret_ref
        }
      }
    }
  }

  ingress {
    external_enabled = true
    target_port      = var.target_port
    transport        = "auto"

    traffic_weight {
      percentage      = 100
      latest_revision = true
    }

    dynamic "ip_security_restriction" {
      for_each = [] # No restrictions by default
      content {
        action           = ip_security_restriction.value.action
        ip_address_range = ip_security_restriction.value.ip_address_range
        name             = ip_security_restriction.value.name
      }
    }
  }

  dynamic "secret" {
    for_each = var.secrets
    content {
      name  = secret.key
      value = secret.value
    }
  }

  lifecycle {
    ignore_changes = [
      # Image is updated by the CI/CD pipeline, not Terraform
      template[0].container[0].image,
    ]
  }
}

# =============================================================================
# ACR Pull permission for the managed identity
# =============================================================================

resource "azurerm_role_assignment" "acr_pull" {
  scope                = azurerm_container_registry.this.id
  role_definition_name = "AcrPull"
  principal_id         = data.azurerm_user_assigned_identity.aca.principal_id
}

data "azurerm_user_assigned_identity" "aca" {
  name                = split("/", var.identity_id)[8]
  resource_group_name = var.resource_group_name
}
