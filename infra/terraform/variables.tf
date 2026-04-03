# =============================================================================
# Core Variables
# =============================================================================

variable "environment_name" {
  type        = string
  description = "Name of the environment, used to generate unique resource names"

  validation {
    condition     = length(var.environment_name) >= 1 && length(var.environment_name) <= 64
    error_message = "Environment name must be between 1 and 64 characters."
  }
}

variable "location" {
  type        = string
  description = "Primary location for all resources"
}

variable "resource_group_name" {
  type        = string
  default     = ""
  description = "Name of the resource group. Auto-generated if empty."
}

variable "principal_id" {
  type        = string
  default     = ""
  description = "ID of the user or app to assign application roles"
}

variable "tenant_id" {
  type        = string
  default     = ""
  description = "Azure tenant ID. Defaults to current tenant."
}

# =============================================================================
# OpenAI Configuration
# =============================================================================

variable "openai_host" {
  type    = string
  default = "azure"

  validation {
    condition     = contains(["azure", "openai", "azure_custom"], var.openai_host)
    error_message = "Must be azure, openai, or azure_custom."
  }
}

variable "openai_service_name" {
  type    = string
  default = ""
}

variable "openai_resource_group_name" {
  type    = string
  default = ""
}

variable "openai_location" {
  type        = string
  default     = ""
  description = "Location for Azure OpenAI. Must support the chosen models."
}

variable "openai_sku_name" {
  type    = string
  default = "S0"
}

variable "azure_openai_custom_url" {
  type    = string
  default = ""
}

variable "azure_openai_api_key" {
  type      = string
  default   = ""
  sensitive = true
}

variable "azure_openai_disable_keys" {
  type    = bool
  default = true
}

variable "openai_api_key" {
  type      = string
  default   = ""
  sensitive = true
}

variable "openai_api_organization" {
  type    = string
  default = ""
}

# ChatGPT model configuration
variable "chatgpt_model_name" {
  type    = string
  default = ""
}

variable "chatgpt_deployment_name" {
  type    = string
  default = ""
}

variable "chatgpt_deployment_version" {
  type    = string
  default = ""
}

variable "chatgpt_deployment_sku_name" {
  type    = string
  default = ""
}

variable "chatgpt_deployment_capacity" {
  type    = number
  default = 0
}

# Embedding model configuration
variable "embedding_model_name" {
  type    = string
  default = ""
}

variable "embedding_deployment_name" {
  type    = string
  default = ""
}

variable "embedding_deployment_version" {
  type    = string
  default = ""
}

variable "embedding_deployment_sku_name" {
  type    = string
  default = ""
}

variable "embedding_deployment_capacity" {
  type    = number
  default = 0
}

variable "embedding_dimensions" {
  type    = number
  default = 0
}

# Eval model configuration
variable "eval_model_name" {
  type    = string
  default = ""
}

variable "eval_deployment_name" {
  type    = string
  default = ""
}

variable "eval_model_version" {
  type    = string
  default = ""
}

variable "eval_deployment_sku_name" {
  type    = string
  default = ""
}

variable "eval_deployment_capacity" {
  type    = number
  default = 0
}

# Knowledge Base model configuration
variable "knowledge_base_model_name" {
  type    = string
  default = ""
}

variable "knowledge_base_deployment_name" {
  type    = string
  default = ""
}

variable "knowledge_base_model_version" {
  type    = string
  default = ""
}

variable "knowledge_base_deployment_sku_name" {
  type    = string
  default = ""
}

variable "knowledge_base_deployment_capacity" {
  type    = number
  default = 0
}

# =============================================================================
# Search Configuration
# =============================================================================

variable "search_service_name" {
  type    = string
  default = ""
}

variable "search_service_resource_group_name" {
  type    = string
  default = ""
}

variable "search_service_location" {
  type    = string
  default = ""
}

variable "search_service_sku_name" {
  type    = string
  default = "basic"

  validation {
    condition     = contains(["free", "basic", "standard", "standard2", "standard3", "storage_optimized_l1", "storage_optimized_l2"], var.search_service_sku_name)
    error_message = "Must be a valid search service SKU."
  }
}

variable "search_index_name" {
  type    = string
  default = "gptkbindex"
}

variable "search_query_language" {
  type    = string
  default = "en-us"
}

variable "search_query_speller" {
  type    = string
  default = "lexicon"
}

variable "search_semantic_ranker_level" {
  type    = string
  default = "free"
}

variable "search_service_query_rewriting" {
  type    = string
  default = "false"
}

variable "search_field_name_embedding" {
  type    = string
  default = "embedding3"
}

# =============================================================================
# Storage Configuration
# =============================================================================

variable "storage_account_name" {
  type    = string
  default = ""
}

variable "storage_resource_group_name" {
  type    = string
  default = ""
}

variable "storage_sku_name" {
  type    = string
  default = "Standard_LRS"
}

variable "storage_container_name" {
  type    = string
  default = "content"
}

# =============================================================================
# Document Intelligence
# =============================================================================

variable "document_intelligence_service_name" {
  type    = string
  default = ""
}

variable "document_intelligence_resource_group_name" {
  type    = string
  default = ""
}

variable "document_intelligence_location" {
  type    = string
  default = ""
}

variable "document_intelligence_sku_name" {
  type    = string
  default = "S0"
}

# =============================================================================
# Vision Service
# =============================================================================

variable "vision_service_name" {
  type    = string
  default = ""
}

variable "vision_resource_group_name" {
  type    = string
  default = ""
}

variable "vision_location" {
  type    = string
  default = "eastus"
}

# =============================================================================
# Content Understanding
# =============================================================================

variable "content_understanding_service_name" {
  type    = string
  default = ""
}

variable "content_understanding_resource_group_name" {
  type    = string
  default = ""
}

# =============================================================================
# Speech Service
# =============================================================================

variable "speech_service_name" {
  type    = string
  default = ""
}

variable "speech_service_resource_group_name" {
  type    = string
  default = ""
}

variable "speech_service_location" {
  type    = string
  default = ""
}

variable "speech_service_sku_name" {
  type    = string
  default = "S0"
}

variable "speech_service_voice" {
  type    = string
  default = ""
}

# =============================================================================
# Cosmos DB
# =============================================================================

variable "cosmosdb_sku_name" {
  type    = string
  default = "serverless"

  validation {
    condition     = contains(["free", "provisioned", "serverless"], var.cosmosdb_sku_name)
    error_message = "Must be free, provisioned, or serverless."
  }
}

variable "cosmosdb_resource_group_name" {
  type    = string
  default = ""
}

variable "cosmosdb_location" {
  type    = string
  default = ""
}

variable "cosmosdb_account_name" {
  type    = string
  default = ""
}

variable "cosmosdb_throughput" {
  type    = number
  default = 400
}

variable "chat_history_database_name" {
  type    = string
  default = "chat-database"
}

variable "chat_history_container_name" {
  type    = string
  default = "chat-history-v2"
}

variable "chat_history_version" {
  type    = string
  default = "cosmosdb-v2"
}

# =============================================================================
# Monitoring
# =============================================================================

variable "application_insights_name" {
  type    = string
  default = ""
}

variable "application_insights_dashboard_name" {
  type    = string
  default = ""
}

variable "log_analytics_name" {
  type    = string
  default = ""
}

# =============================================================================
# Authentication
# =============================================================================

variable "auth_tenant_id" {
  type    = string
  default = ""
}

variable "server_app_id" {
  type    = string
  default = ""
}

variable "server_app_secret" {
  type      = string
  default   = ""
  sensitive = true
}

variable "client_app_id" {
  type    = string
  default = ""
}

variable "client_app_secret" {
  type      = string
  default   = ""
  sensitive = true
}

variable "allowed_origin" {
  type        = string
  default     = ""
  description = "CORS allowed origins, semicolon-separated"
}

# =============================================================================
# Networking
# =============================================================================

variable "public_network_access" {
  type    = string
  default = "Enabled"

  validation {
    condition     = contains(["Enabled", "Disabled"], var.public_network_access)
    error_message = "Must be Enabled or Disabled."
  }
}

variable "bypass" {
  type    = string
  default = "AzureServices"

  validation {
    condition     = contains(["None", "AzureServices"], var.bypass)
    error_message = "Must be None or AzureServices."
  }
}

# =============================================================================
# ADLS Gen2 Storage (Cloud Ingestion)
# =============================================================================

variable "adls_storage_account_name" {
  type    = string
  default = ""
}

variable "adls_storage_resource_group_name" {
  type    = string
  default = ""
}

# =============================================================================
# RAG Configuration
# =============================================================================

variable "default_reasoning_effort" {
  type    = string
  default = "medium"
}

variable "default_retrieval_reasoning_effort" {
  type    = string
  default = "minimal"
}

variable "rag_search_text_embeddings" {
  type    = bool
  default = true
}

variable "rag_search_image_embeddings" {
  type    = bool
  default = true
}

variable "rag_send_text_sources" {
  type    = bool
  default = true
}

variable "rag_send_image_sources" {
  type    = bool
  default = true
}

# =============================================================================
# Container Apps
# =============================================================================

variable "backend_service_name" {
  type    = string
  default = ""
}

variable "aca_identity_name" {
  type    = string
  default = ""
}

variable "container_registry_name" {
  type    = string
  default = ""
}

variable "container_apps_workload_profile" {
  type    = string
  default = "Consumption"

  validation {
    condition     = contains(["Consumption", "D4", "D8", "D16", "D32", "E4", "E8", "E16", "E32", "NC24-A100", "NC48-A100", "NC96-A100"], var.container_apps_workload_profile)
    error_message = "Must be a valid Container Apps workload profile."
  }
}
