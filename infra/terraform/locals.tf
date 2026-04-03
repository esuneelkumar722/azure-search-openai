# =============================================================================
# Computed Values
# =============================================================================

data "azurerm_subscription" "current" {}
data "azurerm_client_config" "current" {}

locals {
  # Resource naming prefix — deterministic hash based on subscription + env + location
  resource_token = lower(substr(md5("${data.azurerm_subscription.current.subscription_id}-${var.environment_name}-${var.location}"), 0, 13))

  tags = {
    "azd-env-name" = var.environment_name
  }

  # Abbreviations (matching infra/abbreviations.json)
  abbrs = {
    resource_groups                   = "rg-"
    storage_accounts                  = "st"
    cognitive_services                = "cog-"
    cognitive_services_vision         = "cog-vz-"
    cognitive_services_doc_intel      = "cog-di-"
    cognitive_services_speech         = "cog-sp-"
    cognitive_services_content_understanding = "cu-"
    search_services                   = "srch-"
    insights_components               = "appi-"
    operational_insights_workspaces   = "log-"
    portal_dashboards                 = "dash-"
    managed_identity                  = "id-"
    web_sites_container_apps          = "capps-"
    container_registry                = "cr"
    app_managed_environments          = "cae-"
    web_sites_functions               = "func-"
    document_db                       = "cosmos-"
    virtual_networks                  = "vnet-"
    vpn_gateways                      = "vpng-"
    private_dns_resolver              = "pdr-"
  }

  # Tenant ID — use provided or default to current
  tenant_id          = var.tenant_id != "" ? var.tenant_id : data.azurerm_client_config.current.tenant_id
  tenant_id_for_auth = var.auth_tenant_id != "" ? var.auth_tenant_id : local.tenant_id
  authentication_issuer_uri = "https://login.microsoftonline.com/${local.tenant_id_for_auth}/v2.0"

  # OpenAI host flags
  is_azure_openai_host = startswith(var.openai_host, "azure")
  deploy_azure_openai  = var.openai_host == "azure"

  # ChatGPT model defaults
  chatgpt = {
    model_name         = var.chatgpt_model_name != "" ? var.chatgpt_model_name : "gpt-4.1-mini"
    deployment_name    = var.chatgpt_deployment_name != "" ? var.chatgpt_deployment_name : "gpt-4.1-mini"
    deployment_version = var.chatgpt_deployment_version != "" ? var.chatgpt_deployment_version : "2025-04-14"
    deployment_sku     = var.chatgpt_deployment_sku_name != "" ? var.chatgpt_deployment_sku_name : "GlobalStandard"
    deployment_capacity = var.chatgpt_deployment_capacity != 0 ? var.chatgpt_deployment_capacity : 30
  }

  # Embedding model defaults
  embedding = {
    model_name         = var.embedding_model_name != "" ? var.embedding_model_name : "text-embedding-3-large"
    deployment_name    = var.embedding_deployment_name != "" ? var.embedding_deployment_name : "text-embedding-3-large"
    deployment_version = var.embedding_deployment_version != "" ? var.embedding_deployment_version : (var.embedding_model_name == "text-embedding-ada-002" ? "2" : "1")
    deployment_sku     = var.embedding_deployment_sku_name != "" ? var.embedding_deployment_sku_name : (var.embedding_model_name == "text-embedding-ada-002" ? "Standard" : "GlobalStandard")
    deployment_capacity = var.embedding_deployment_capacity != 0 ? var.embedding_deployment_capacity : 200
    dimensions         = var.embedding_dimensions != 0 ? var.embedding_dimensions : 3072
  }

  # Eval model defaults
  eval = {
    model_name         = var.eval_model_name != "" ? var.eval_model_name : "gpt-4o"
    deployment_name    = var.eval_deployment_name != "" ? var.eval_deployment_name : "eval"
    deployment_version = var.eval_model_version != "" ? var.eval_model_version : "2024-08-06"
    deployment_sku     = var.eval_deployment_sku_name != "" ? var.eval_deployment_sku_name : "GlobalStandard"
    deployment_capacity = var.eval_deployment_capacity != 0 ? var.eval_deployment_capacity : 30
  }

  # Knowledge Base model defaults
  knowledge_base = {
    model_name         = var.knowledge_base_model_name != "" ? var.knowledge_base_model_name : "gpt-4.1-mini"
    deployment_name    = var.knowledge_base_deployment_name != "" ? var.knowledge_base_deployment_name : "knowledgebase"
    deployment_version = var.knowledge_base_model_version != "" ? var.knowledge_base_model_version : "2025-04-14"
    deployment_sku     = var.knowledge_base_deployment_sku_name != "" ? var.knowledge_base_deployment_sku_name : "GlobalStandard"
    deployment_capacity = var.knowledge_base_deployment_capacity != 0 ? var.knowledge_base_deployment_capacity : 100
  }

  # Search configuration
  actual_search_semantic_ranker_level = var.search_service_sku_name == "free" ? "disabled" : var.search_semantic_ranker_level
  knowledge_base_name = var.use_agentic_knowledgebase ? "${var.search_index_name}-agent-upgrade" : ""

  # CORS origins
  msft_allowed_origins    = ["https://portal.azure.com", "https://ms.portal.azure.com"]
  login_endpoint          = "https://login.microsoftonline.com"
  all_msft_allowed_origins = var.client_app_id != "" ? concat(local.msft_allowed_origins, [local.login_endpoint]) : local.msft_allowed_origins
  custom_origins          = var.allowed_origin != "" ? split(";", var.allowed_origin) : []
  allowed_origins         = distinct(concat(local.custom_origins, local.all_msft_allowed_origins))

  # Principal type for RBAC
  principal_type = "User"

  # Resource names — use provided or generate from token
  resource_group_name_resolved = var.resource_group_name != "" ? var.resource_group_name : "${local.abbrs.resource_groups}${var.environment_name}"

  # Container image storage containers
  storage_container_name       = var.storage_container_name
  image_storage_container_name = "images"
  token_storage_container_name = "tokens"
  user_storage_container_name  = "user-content"
}
