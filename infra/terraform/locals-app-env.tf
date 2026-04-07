# =============================================================================
# Application Environment Variables

# These are passed to the Container App as environment variables.
# =============================================================================

locals {
  # Resolve ADLS storage account name
  adls_storage_account_name_resolved = (
    var.use_existing_adls_storage ? var.adls_storage_account_name :
    var.use_cloud_ingestion_acls && !var.use_existing_adls_storage ? module.adls_storage[0].name : ""
  )
  cloud_ingestion_storage_account = var.use_cloud_ingestion_acls ? local.adls_storage_account_name_resolved : module.storage.name

  app_env_variables = {
    AZURE_STORAGE_ACCOUNT                 = module.storage.name
    AZURE_STORAGE_CONTAINER               = local.storage_container_name
    AZURE_STORAGE_RESOURCE_GROUP          = azurerm_resource_group.main.name
    AZURE_CLOUD_INGESTION_STORAGE_ACCOUNT = local.cloud_ingestion_storage_account
    USE_CLOUD_INGESTION_ACLS              = tostring(var.use_cloud_ingestion_acls)
    AZURE_SUBSCRIPTION_ID                 = data.azurerm_subscription.current.subscription_id
    AZURE_SEARCH_INDEX                    = var.search_index_name
    AZURE_SEARCH_KNOWLEDGEBASE_NAME       = local.knowledge_base_name
    AZURE_SEARCH_SERVICE                  = module.search.name
    AZURE_SEARCH_SEMANTIC_RANKER          = local.actual_search_semantic_ranker_level
    AZURE_SEARCH_QUERY_REWRITING          = var.search_service_query_rewriting
    AZURE_VISION_ENDPOINT                 = var.use_multimodal ? module.vision[0].endpoint : ""
    AZURE_SEARCH_QUERY_LANGUAGE           = var.search_query_language
    AZURE_SEARCH_QUERY_SPELLER            = var.search_query_speller
    AZURE_SEARCH_FIELD_NAME_EMBEDDING     = var.search_field_name_embedding
    APPLICATIONINSIGHTS_CONNECTION_STRING  = var.use_application_insights ? module.monitoring[0].connection_string : ""
    AZURE_SPEECH_SERVICE_ID               = var.use_speech_output_azure ? module.speech[0].id : ""
    AZURE_SPEECH_SERVICE_LOCATION         = var.use_speech_output_azure ? module.speech[0].location : ""
    AZURE_SPEECH_SERVICE_VOICE            = var.use_speech_output_azure ? var.speech_service_voice : ""
    ENABLE_LANGUAGE_PICKER                = tostring(var.enable_language_picker)
    USE_SPEECH_INPUT_BROWSER              = tostring(var.use_speech_input_browser)
    USE_SPEECH_OUTPUT_BROWSER             = tostring(var.use_speech_output_browser)
    USE_SPEECH_OUTPUT_AZURE               = tostring(var.use_speech_output_azure)
    USE_AGENTIC_KNOWLEDGEBASE             = tostring(var.use_agentic_knowledgebase)
    USE_CHAT_HISTORY_BROWSER              = tostring(var.use_chat_history_browser)
    USE_CHAT_HISTORY_COSMOS               = tostring(var.use_chat_history_cosmos)
    AZURE_COSMOSDB_ACCOUNT                = var.use_chat_history_cosmos ? module.cosmosdb[0].account_name : ""
    AZURE_CHAT_HISTORY_DATABASE           = var.chat_history_database_name
    AZURE_CHAT_HISTORY_CONTAINER          = var.chat_history_container_name
    AZURE_CHAT_HISTORY_VERSION            = var.chat_history_version
    OPENAI_HOST                           = var.openai_host
    AZURE_OPENAI_EMB_MODEL_NAME           = local.embedding.model_name
    AZURE_OPENAI_EMB_DIMENSIONS           = tostring(local.embedding.dimensions)
    AZURE_OPENAI_CHATGPT_MODEL            = local.chatgpt.model_name
    AZURE_OPENAI_REASONING_EFFORT         = var.default_reasoning_effort
    AGENTIC_KNOWLEDGEBASE_REASONING_EFFORT = var.default_retrieval_reasoning_effort
    AZURE_OPENAI_SERVICE                  = local.is_azure_openai_host && local.deploy_azure_openai ? module.openai[0].name : ""
    AZURE_OPENAI_CHATGPT_DEPLOYMENT       = local.chatgpt.deployment_name
    AZURE_OPENAI_EMB_DEPLOYMENT           = local.embedding.deployment_name
    AZURE_OPENAI_KNOWLEDGEBASE_MODEL      = var.use_agentic_knowledgebase ? local.knowledge_base.model_name : ""
    AZURE_OPENAI_KNOWLEDGEBASE_DEPLOYMENT = var.use_agentic_knowledgebase ? local.knowledge_base.deployment_name : ""
    AZURE_OPENAI_API_KEY_OVERRIDE         = var.azure_openai_api_key
    AZURE_OPENAI_CUSTOM_URL               = var.azure_openai_custom_url
    OPENAI_API_KEY                        = var.openai_api_key
    OPENAI_ORGANIZATION                   = var.openai_api_organization
    AZURE_USE_AUTHENTICATION              = tostring(var.use_authentication)
    AZURE_ENFORCE_ACCESS_CONTROL          = tostring(var.enforce_access_control)
    AZURE_ENABLE_GLOBAL_DOCUMENT_ACCESS   = tostring(var.enable_global_documents)
    AZURE_ENABLE_UNAUTHENTICATED_ACCESS   = tostring(var.enable_unauthenticated_access)
    AZURE_SERVER_APP_ID                   = var.server_app_id
    AZURE_CLIENT_APP_ID                   = var.client_app_id
    AZURE_TENANT_ID                       = local.tenant_id
    AZURE_AUTH_TENANT_ID                  = local.tenant_id_for_auth
    AZURE_AUTHENTICATION_ISSUER_URI       = local.authentication_issuer_uri
    ALLOWED_ORIGIN                        = join(";", local.allowed_origins)
    USE_VECTORS                           = tostring(var.use_vectors)
    USE_MULTIMODAL                        = tostring(var.use_multimodal)
    USE_USER_UPLOAD                       = tostring(var.use_user_upload)
    AZURE_USERSTORAGE_ACCOUNT             = var.use_user_upload ? module.user_storage[0].name : ""
    AZURE_USERSTORAGE_CONTAINER           = var.use_user_upload ? local.user_storage_container_name : ""
    AZURE_IMAGESTORAGE_CONTAINER          = var.use_multimodal ? local.image_storage_container_name : ""
    AZURE_DOCUMENTINTELLIGENCE_SERVICE    = module.document_intelligence.name
    USE_LOCAL_PDF_PARSER                  = tostring(var.use_local_pdf_parser)
    USE_LOCAL_HTML_PARSER                 = tostring(var.use_local_html_parser)
    USE_MEDIA_DESCRIBER_AZURE_CU          = tostring(var.use_media_describer_azure_cu)
    AZURE_CONTENTUNDERSTANDING_ENDPOINT   = var.use_media_describer_azure_cu ? module.content_understanding[0].endpoint : ""
    RUNNING_IN_PRODUCTION                 = "true"
    RAG_SEARCH_TEXT_EMBEDDINGS            = tostring(var.rag_search_text_embeddings)
    RAG_SEARCH_IMAGE_EMBEDDINGS           = tostring(var.rag_search_image_embeddings)
    RAG_SEND_TEXT_SOURCES                 = tostring(var.rag_send_text_sources)
    RAG_SEND_IMAGE_SOURCES                = tostring(var.rag_send_image_sources)
    USE_WEB_SOURCE                        = tostring(var.use_web_source)
    USE_SHAREPOINT_SOURCE                 = tostring(var.use_sharepoint_source)
    # Container Apps specific
    AZURE_CLIENT_ID                       = module.identity.client_id
  }

  # Secrets for auth (passed as Container App secrets)
  app_secrets = {
    azureclientappsecret = var.client_app_secret
    azureserverappsecret = var.server_app_secret
  }

  app_env_secrets = [
    {
      name       = "AZURE_CLIENT_APP_SECRET"
      secret_ref = "azureclientappsecret"
    },
    {
      name       = "AZURE_SERVER_APP_SECRET"
      secret_ref = "azureserverappsecret"
    },
  ]

  # Private endpoint connections (Phase 7)
  openai_pe_connections = local.deploy_azure_openai && var.use_private_endpoint ? [
    {
      group_id     = "account"
      dns_zone_name = "privatelink.openai.azure.com"
      resource_ids = [module.openai[0].id]
    }
  ] : []

  cognitive_pe_connections = var.use_private_endpoint && (!var.use_local_pdf_parser || var.use_multimodal || var.use_media_describer_azure_cu) ? [
    {
      group_id     = "account"
      dns_zone_name = "privatelink.cognitiveservices.azure.com"
      resource_ids = concat(
        !var.use_local_pdf_parser ? [module.document_intelligence.id] : [],
        var.use_multimodal ? [module.vision[0].id] : [],
        var.use_media_describer_azure_cu ? [module.content_understanding[0].id] : []
      )
    }
  ] : []

  container_apps_pe_connections = var.use_private_endpoint ? [
    {
      group_id     = "managedEnvironments"
      dns_zone_name = "privatelink.${var.location}.azurecontainerapps.io"
      resource_ids = [module.container_apps.environment_id]
    }
  ] : []

  other_pe_connections = var.use_private_endpoint ? [
    {
      group_id     = "blob"
      dns_zone_name = "privatelink.blob.core.windows.net"
      resource_ids = concat(
        [module.storage.id],
        var.use_user_upload ? [module.user_storage[0].id] : []
      )
    },
    {
      group_id     = "searchService"
      dns_zone_name = "privatelink.search.windows.net"
      resource_ids = [module.search.id]
    },
    {
      group_id     = "sql"
      dns_zone_name = "privatelink.documents.azure.com"
      resource_ids = var.use_authentication && var.use_chat_history_cosmos ? [module.cosmosdb[0].id] : []
    },
  ] : []

  private_endpoint_connections = concat(
    local.other_pe_connections,
    local.openai_pe_connections,
    local.cognitive_pe_connections,
    local.container_apps_pe_connections
  )
}
