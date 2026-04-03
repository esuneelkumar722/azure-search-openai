# =============================================================================
# Outputs — mirrors main.bicep lines 1537-1622
# =============================================================================

output "azure_location" {
  value = var.location
}

output "azure_tenant_id" {
  value = local.tenant_id
}

output "azure_auth_tenant_id" {
  value = var.auth_tenant_id
}

output "azure_resource_group" {
  value = azurerm_resource_group.main.name
}

# OpenAI outputs
output "openai_host" {
  value = var.openai_host
}

output "azure_openai_emb_model_name" {
  value = local.embedding.model_name
}

output "azure_openai_emb_dimensions" {
  value = local.embedding.dimensions
}

output "azure_openai_chatgpt_model" {
  value = local.chatgpt.model_name
}

output "azure_openai_service" {
  value = local.is_azure_openai_host && local.deploy_azure_openai ? module.openai[0].name : ""
}

output "azure_openai_endpoint" {
  value = local.is_azure_openai_host && local.deploy_azure_openai ? module.openai[0].endpoint : ""
}

output "azure_openai_resource_group" {
  value = local.is_azure_openai_host ? azurerm_resource_group.main.name : ""
}

output "azure_openai_chatgpt_deployment" {
  value = local.is_azure_openai_host ? local.chatgpt.deployment_name : ""
}

output "azure_openai_chatgpt_deployment_version" {
  value = local.is_azure_openai_host ? local.chatgpt.deployment_version : ""
}

output "azure_openai_chatgpt_deployment_sku" {
  value = local.is_azure_openai_host ? local.chatgpt.deployment_sku : ""
}

output "azure_openai_emb_deployment" {
  value = local.is_azure_openai_host ? local.embedding.deployment_name : ""
}

output "azure_openai_emb_deployment_version" {
  value = local.is_azure_openai_host ? local.embedding.deployment_version : ""
}

output "azure_openai_emb_deployment_sku" {
  value = local.is_azure_openai_host ? local.embedding.deployment_sku : ""
}

output "azure_openai_eval_deployment" {
  value = local.is_azure_openai_host && var.use_eval ? local.eval.deployment_name : ""
}

output "azure_openai_eval_model" {
  value = local.is_azure_openai_host && var.use_eval ? local.eval.model_name : ""
}

output "azure_openai_knowledgebase_deployment" {
  value = local.is_azure_openai_host && var.use_agentic_knowledgebase ? local.knowledge_base.deployment_name : ""
}

output "azure_openai_knowledgebase_model" {
  value = local.is_azure_openai_host && var.use_agentic_knowledgebase ? local.knowledge_base.model_name : ""
}

output "azure_openai_reasoning_effort" {
  value = var.default_reasoning_effort
}

output "azure_search_knowledgebase_retrieval_reasoning_effort" {
  value = var.default_retrieval_reasoning_effort
}

# Speech outputs
output "azure_speech_service_id" {
  value = var.use_speech_output_azure ? module.speech[0].id : ""
}

output "azure_speech_service_location" {
  value = var.use_speech_output_azure ? module.speech[0].location : ""
}

# Vision outputs
output "azure_vision_endpoint" {
  value = var.use_multimodal ? module.vision[0].endpoint : ""
}

output "azure_contentunderstanding_endpoint" {
  value = var.use_media_describer_azure_cu ? module.content_understanding[0].endpoint : ""
}

# Document Intelligence outputs
output "azure_documentintelligence_service" {
  value = module.document_intelligence.name
}

output "azure_documentintelligence_resource_group" {
  value = azurerm_resource_group.main.name
}

# Search outputs
output "azure_search_index" {
  value = var.search_index_name
}

output "azure_search_knowledgebase_name" {
  value = local.knowledge_base_name
}

output "azure_search_service" {
  value = module.search.name
}

output "azure_search_service_resource_group" {
  value = azurerm_resource_group.main.name
}

output "azure_search_semantic_ranker" {
  value = local.actual_search_semantic_ranker_level
}

output "azure_search_field_name_embedding" {
  value = var.search_field_name_embedding
}

# Cosmos DB outputs
output "azure_cosmosdb_account" {
  value = var.use_authentication && var.use_chat_history_cosmos ? module.cosmosdb[0].account_name : ""
}

output "azure_chat_history_database" {
  value = var.chat_history_database_name
}

output "azure_chat_history_container" {
  value = var.chat_history_container_name
}

output "azure_chat_history_version" {
  value = var.chat_history_version
}

# Storage outputs
output "azure_storage_account" {
  value = module.storage.name
}

output "azure_storage_container" {
  value = local.storage_container_name
}

output "azure_storage_resource_group" {
  value = azurerm_resource_group.main.name
}

output "azure_userstorage_account" {
  value = var.use_user_upload ? module.user_storage[0].name : ""
}

output "azure_userstorage_container" {
  value = local.user_storage_container_name
}

# Cloud ingestion outputs
output "azure_cloud_ingestion_storage_account" {
  value = var.use_cloud_ingestion_acls ? local.adls_storage_account_name_resolved : module.storage.name
}

# AI Project output
output "azure_ai_project" {
  value = var.use_ai_project ? module.ai_project[0].project_name : ""
}

# Auth output
output "azure_use_authentication" {
  value = var.use_authentication
}

# Hosting outputs
output "backend_uri" {
  value = module.container_apps.app_uri
}

output "azure_container_registry_endpoint" {
  value = module.container_apps.registry_login_server
}

output "azure_container_registry_name" {
  value = module.container_apps.registry_name
}

output "backend_container_app_name" {
  value = module.container_apps.app_name
}

# Cloud ingestion function outputs
output "document_extractor_skill_endpoint" {
  value = var.use_cloud_ingestion ? "https://${module.functions[0].document_extractor_url}/api/extract" : ""
}

output "figure_processor_skill_endpoint" {
  value = var.use_cloud_ingestion ? "https://${module.functions[0].figure_processor_url}/api/process" : ""
}

output "text_processor_skill_endpoint" {
  value = var.use_cloud_ingestion ? "https://${module.functions[0].text_processor_url}/api/process" : ""
}
