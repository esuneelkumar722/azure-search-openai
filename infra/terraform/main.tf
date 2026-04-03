# =============================================================================
# Root Module — Resource Group + Module Calls
# =============================================================================

resource "azurerm_resource_group" "main" {
  name     = local.resource_group_name_resolved
  location = var.location
  tags     = local.tags
}

# =============================================================================
# Phase 1: Core Shared Resources
# =============================================================================

module "monitoring" {
  source = "./modules/monitoring"
  count  = var.use_application_insights ? 1 : 0

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  tags                = local.tags

  application_insights_name = var.application_insights_name != "" ? var.application_insights_name : "${local.abbrs.insights_components}${local.resource_token}"
  log_analytics_name        = var.log_analytics_name != "" ? var.log_analytics_name : "${local.abbrs.operational_insights_workspaces}${local.resource_token}"
  dashboard_name            = var.application_insights_dashboard_name != "" ? var.application_insights_dashboard_name : "${local.abbrs.portal_dashboards}${local.resource_token}"
  public_network_access     = var.public_network_access
}

module "storage" {
  source = "./modules/storage"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  tags                = local.tags

  name                  = var.storage_account_name != "" ? var.storage_account_name : "${local.abbrs.storage_accounts}${local.resource_token}"
  sku_name              = var.storage_sku_name
  public_network_access = var.public_network_access
  bypass                = var.bypass

  containers = [
    local.storage_container_name,
    local.image_storage_container_name,
    local.token_storage_container_name,
  ]
}

# User upload storage (ADLS Gen2 with HNS)
module "user_storage" {
  source = "./modules/storage"
  count  = var.use_user_upload ? 1 : 0

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  tags                = local.tags

  name                  = "user${local.abbrs.storage_accounts}${local.resource_token}"
  sku_name              = var.storage_sku_name
  public_network_access = var.public_network_access
  bypass                = var.bypass
  is_hns_enabled        = true

  containers = [local.user_storage_container_name]
}

# ADLS Gen2 storage for cloud ingestion with ACL support
module "adls_storage" {
  source = "./modules/storage"
  count  = var.use_cloud_ingestion_acls && !var.use_existing_adls_storage ? 1 : 0

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  tags                = local.tags

  name                  = "adls${local.abbrs.storage_accounts}${local.resource_token}"
  sku_name              = var.storage_sku_name
  public_network_access = var.public_network_access
  bypass                = var.bypass
  is_hns_enabled        = true

  containers = [local.storage_container_name]
}

# =============================================================================
# Phase 2: AI / Cognitive Services
# =============================================================================

module "openai" {
  source = "./modules/openai"
  count  = local.is_azure_openai_host && local.deploy_azure_openai ? 1 : 0

  resource_group_name = azurerm_resource_group.main.name
  location            = var.openai_location != "" ? var.openai_location : var.location
  tags                = local.tags

  name                  = var.openai_service_name != "" ? var.openai_service_name : "${local.abbrs.cognitive_services}${local.resource_token}"
  sku_name              = var.openai_sku_name
  public_network_access = var.public_network_access
  bypass                = var.bypass
  disable_local_auth    = var.azure_openai_disable_keys

  chatgpt        = local.chatgpt
  embedding      = local.embedding
  eval           = var.use_eval ? local.eval : null
  knowledge_base = var.use_agentic_knowledgebase ? local.knowledge_base : null
}

module "document_intelligence" {
  source = "./modules/document-intelligence"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.document_intelligence_location != "" ? var.document_intelligence_location : var.location
  tags                = local.tags

  name                  = var.document_intelligence_service_name != "" ? var.document_intelligence_service_name : "${local.abbrs.cognitive_services_doc_intel}${local.resource_token}"
  sku_name              = var.document_intelligence_sku_name
  public_network_access = var.public_network_access
}

module "vision" {
  source = "./modules/vision"
  count  = var.use_multimodal ? 1 : 0

  resource_group_name = azurerm_resource_group.main.name
  location            = var.vision_location
  tags                = local.tags

  name = var.vision_service_name != "" ? var.vision_service_name : "${local.abbrs.cognitive_services_vision}${local.resource_token}"
}

module "content_understanding" {
  source = "./modules/content-understanding"
  count  = var.use_media_describer_azure_cu ? 1 : 0

  resource_group_name = azurerm_resource_group.main.name
  location            = "westus" # Hard-coded due to limited availability
  tags                = local.tags

  name = var.content_understanding_service_name != "" ? var.content_understanding_service_name : "${local.abbrs.cognitive_services_content_understanding}${local.resource_token}"
}

module "speech" {
  source = "./modules/speech"
  count  = var.use_speech_output_azure ? 1 : 0

  resource_group_name = azurerm_resource_group.main.name
  location            = var.speech_service_location != "" ? var.speech_service_location : var.location
  tags                = local.tags

  name     = var.speech_service_name != "" ? var.speech_service_name : "${local.abbrs.cognitive_services_speech}${local.resource_token}"
  sku_name = var.speech_service_sku_name
}

# =============================================================================
# Phase 3: Search Service
# =============================================================================

module "search" {
  source = "./modules/search"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.search_service_location != "" ? var.search_service_location : var.location
  tags                = local.tags

  name                  = var.search_service_name != "" ? var.search_service_name : "gptkb-${local.resource_token}"
  sku_name              = var.search_service_sku_name
  semantic_search       = local.actual_search_semantic_ranker_level
  public_network_access = var.public_network_access

  log_analytics_workspace_id = var.use_application_insights ? module.monitoring[0].log_analytics_workspace_id : ""
  use_application_insights   = var.use_application_insights

  # For integrated vectorization with private endpoints
  shared_private_link_storage_accounts = var.use_private_endpoint && var.use_integrated_vectorization ? [module.storage.id] : []
}

# =============================================================================
# Phase 4: Container Apps Hosting
# =============================================================================

module "identity" {
  source = "./modules/identity"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location

  name = var.aca_identity_name != "" ? var.aca_identity_name : "${var.environment_name}-aca-identity"
}

module "container_apps" {
  source = "./modules/container-apps"

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  tags                = local.tags

  environment_name       = "${var.environment_name}-aca-env"
  registry_name          = var.container_registry_name != "" ? var.container_registry_name : "${replace(lower(var.environment_name), "-", "")}acr${local.resource_token}"
  log_analytics_workspace_name = var.use_application_insights ? module.monitoring[0].log_analytics_workspace_name : ""
  log_analytics_workspace_id   = var.use_application_insights ? module.monitoring[0].log_analytics_workspace_id : ""
  subnet_resource_id     = var.use_private_endpoint ? module.networking[0].app_subnet_id : ""
  use_private_ingress    = var.use_private_endpoint
  workload_profile       = var.container_apps_workload_profile

  # Container App configuration
  app_name              = var.backend_service_name != "" ? var.backend_service_name : "${local.abbrs.web_sites_container_apps}backend-${local.resource_token}"
  identity_id           = module.identity.id
  identity_client_id    = module.identity.client_id
  target_port           = 8000
  cpu                   = "1.0"
  memory                = "2Gi"
  min_replicas          = var.use_private_endpoint ? 1 : 0
  allowed_origins       = local.allowed_origins

  env_variables = local.app_env_variables
  secrets       = var.use_authentication ? local.app_secrets : {}
  env_secrets   = var.use_authentication ? local.app_env_secrets : []
}

# =============================================================================
# Phase 5: RBAC Role Assignments
# =============================================================================

module "rbac" {
  source = "./modules/rbac"

  resource_group_id      = azurerm_resource_group.main.id
  principal_id           = var.principal_id
  principal_type         = local.principal_type
  backend_principal_id   = module.container_apps.app_identity_principal_id

  # Service resource IDs for scoping
  openai_id              = local.deploy_azure_openai ? module.openai[0].id : ""
  search_id              = module.search.id
  storage_id             = module.storage.id
  search_principal_id    = module.search.system_identity_principal_id

  # Feature flags that affect which roles are created
  deploy_azure_openai          = local.deploy_azure_openai
  is_azure_openai_host         = local.is_azure_openai_host
  search_service_sku_name      = var.search_service_sku_name
  use_multimodal               = var.use_multimodal
  use_user_upload              = var.use_user_upload
  use_authentication           = var.use_authentication
  use_chat_history_cosmos      = var.use_chat_history_cosmos
  use_integrated_vectorization = var.use_integrated_vectorization
  use_cloud_ingestion          = var.use_cloud_ingestion
  use_cloud_ingestion_acls     = var.use_cloud_ingestion_acls
  use_speech_output_azure      = var.use_speech_output_azure

  # Optional resource IDs (only available when feature flags are enabled)
  vision_id               = var.use_multimodal ? module.vision[0].id : ""
  cosmosdb_account_name   = var.use_authentication && var.use_chat_history_cosmos ? module.cosmosdb[0].account_name : ""
  cosmosdb_id             = var.use_authentication && var.use_chat_history_cosmos ? module.cosmosdb[0].id : ""
  user_storage_id         = var.use_user_upload ? module.user_storage[0].id : ""
  functions_principal_id  = var.use_cloud_ingestion ? module.functions[0].principal_id : ""
  client_app_id           = var.client_app_id
}

# =============================================================================
# Phase 6: Optional Services
# =============================================================================

module "cosmosdb" {
  source = "./modules/cosmosdb"
  count  = var.use_authentication && var.use_chat_history_cosmos ? 1 : 0

  resource_group_name = azurerm_resource_group.main.name
  location            = var.cosmosdb_location != "" ? var.cosmosdb_location : var.location
  tags                = local.tags

  name                       = var.cosmosdb_account_name != "" ? var.cosmosdb_account_name : "${local.abbrs.document_db}${local.resource_token}"
  sku_name                   = var.cosmosdb_sku_name
  throughput                 = var.cosmosdb_throughput
  public_network_access      = var.public_network_access
  bypass                     = var.bypass
  chat_history_database_name = var.chat_history_database_name
  chat_history_container_name = var.chat_history_container_name
}

module "ai_project" {
  source = "./modules/ai-project"
  count  = var.use_ai_project ? 1 : 0

  resource_group_name = azurerm_resource_group.main.name
  location            = "eastus2" # Limited region support
  tags                = local.tags

  hub_name                = "aihub-${local.resource_token}"
  project_name            = "aiproj-${local.resource_token}"
  storage_account_id      = module.storage.id
  application_insights_id = var.use_application_insights ? module.monitoring[0].application_insights_id : ""
}

module "functions" {
  source = "./modules/functions"
  count  = var.use_cloud_ingestion ? 1 : 0

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  tags                = local.tags

  document_extractor_name = "${local.abbrs.web_sites_functions}doc-extractor-${local.resource_token}"
  figure_processor_name   = "${local.abbrs.web_sites_functions}figure-processor-${local.resource_token}"
  text_processor_name     = "${local.abbrs.web_sites_functions}text-processor-${local.resource_token}"

  application_insights_name = var.use_application_insights ? module.monitoring[0].application_insights_name : ""
  app_env_variables         = local.app_env_variables
}

# =============================================================================
# Phase 7: Private Networking
# =============================================================================

module "networking" {
  source = "./modules/networking"
  count  = var.use_private_endpoint ? 1 : 0

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  tags                = local.tags

  vnet_name         = "${local.abbrs.virtual_networks}${local.resource_token}"
  use_vpn_gateway   = var.use_vpn_gateway
  vpn_gateway_name  = var.use_vpn_gateway ? "${local.abbrs.vpn_gateways}${local.resource_token}" : ""
  dns_resolver_name = var.use_vpn_gateway ? "${local.abbrs.private_dns_resolver}${local.resource_token}" : ""
}

module "private_endpoints" {
  source = "./modules/private-endpoints"
  count  = var.use_private_endpoint ? 1 : 0

  resource_group_name = azurerm_resource_group.main.name
  location            = var.location
  tags                = local.tags

  resource_token = local.resource_token
  vnet_name      = module.networking[0].vnet_name
  vnet_subnet_id = module.networking[0].backend_subnet_id

  private_endpoint_connections = local.private_endpoint_connections

  application_insights_id    = var.use_application_insights ? module.monitoring[0].application_insights_id : ""
  log_analytics_workspace_id = var.use_application_insights ? module.monitoring[0].log_analytics_workspace_id : ""
}
