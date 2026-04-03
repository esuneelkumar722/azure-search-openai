resource "azurerm_cognitive_account" "this" {
  name                          = var.name
  resource_group_name           = var.resource_group_name
  location                      = var.location
  kind                          = "OpenAI"
  sku_name                      = var.sku_name
  custom_subdomain_name         = var.name
  public_network_access_enabled = var.public_network_access == "Enabled"
  local_auth_enabled            = !var.disable_local_auth
  tags                          = var.tags

  network_acls {
    default_action = "Allow"
    ip_rules       = []
  }

  identity {
    type = "SystemAssigned"
  }
}

# ChatGPT deployment (always created)
resource "azurerm_cognitive_deployment" "chatgpt" {
  name                 = var.chatgpt.deployment_name
  cognitive_account_id = azurerm_cognitive_account.this.id

  model {
    format  = "OpenAI"
    name    = var.chatgpt.model_name
    version = var.chatgpt.deployment_version
  }

  sku {
    name     = var.chatgpt.deployment_sku
    capacity = var.chatgpt.deployment_capacity
  }
}

# Embedding deployment (always created)
resource "azurerm_cognitive_deployment" "embedding" {
  name                 = var.embedding.deployment_name
  cognitive_account_id = azurerm_cognitive_account.this.id

  model {
    format  = "OpenAI"
    name    = var.embedding.model_name
    version = var.embedding.deployment_version
  }

  sku {
    name     = var.embedding.deployment_sku
    capacity = var.embedding.deployment_capacity
  }

  depends_on = [azurerm_cognitive_deployment.chatgpt]
}

# Eval deployment (optional)
resource "azurerm_cognitive_deployment" "eval" {
  count                = var.eval != null ? 1 : 0
  name                 = var.eval.deployment_name
  cognitive_account_id = azurerm_cognitive_account.this.id

  model {
    format  = "OpenAI"
    name    = var.eval.model_name
    version = var.eval.deployment_version
  }

  sku {
    name     = var.eval.deployment_sku
    capacity = var.eval.deployment_capacity
  }

  depends_on = [azurerm_cognitive_deployment.embedding]
}

# Knowledge Base deployment (optional)
resource "azurerm_cognitive_deployment" "knowledge_base" {
  count                = var.knowledge_base != null ? 1 : 0
  name                 = var.knowledge_base.deployment_name
  cognitive_account_id = azurerm_cognitive_account.this.id

  model {
    format  = "OpenAI"
    name    = var.knowledge_base.model_name
    version = var.knowledge_base.deployment_version
  }

  sku {
    name     = var.knowledge_base.deployment_sku
    capacity = var.knowledge_base.deployment_capacity
  }

  depends_on = [azurerm_cognitive_deployment.eval]
}
