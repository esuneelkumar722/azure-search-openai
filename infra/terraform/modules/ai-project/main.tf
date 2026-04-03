# Azure AI Foundry Hub and Project
# Uses azapi provider for Hub/Project kinds not yet supported by azurerm.
# This module is only deployed when use_ai_project = true.
#
# TODO: Replace with azurerm resources when Hub/Project kinds are supported.

data "azurerm_client_config" "current" {}

resource "azurerm_key_vault" "ai" {
  name                = "kv-${substr(var.hub_name, 0, 14)}"
  resource_group_name = var.resource_group_name
  location            = var.location
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"
  tags                = var.tags
}

resource "azurerm_machine_learning_workspace" "hub" {
  name                = var.hub_name
  resource_group_name = var.resource_group_name
  location            = var.location
  tags                = var.tags

  storage_account_id      = var.storage_account_id
  key_vault_id            = azurerm_key_vault.ai.id
  application_insights_id = var.application_insights_id != "" ? var.application_insights_id : null

  identity {
    type = "SystemAssigned"
  }
}
