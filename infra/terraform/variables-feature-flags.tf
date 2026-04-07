# =============================================================================
# Feature Flags
# These control which optional Azure resources are deployed.

# =============================================================================

variable "use_vectors" {
  type        = bool
  default     = true
  description = "Enable vector embeddings for search"
}

variable "use_integrated_vectorization" {
  type        = bool
  default     = false
  description = "Use AI Search built-in integrated vectorization"
}

variable "use_multimodal" {
  type        = bool
  default     = false
  description = "Enable image understanding via Azure Vision"
}

variable "use_eval" {
  type        = bool
  default     = false
  description = "Deploy evaluation model (gpt-4o)"
}

variable "use_cloud_ingestion" {
  type        = bool
  default     = false
  description = "Deploy Azure Functions for cloud-based document processing"
}

variable "use_cloud_ingestion_acls" {
  type        = bool
  default     = false
  description = "Enable ACL extraction from documents during cloud ingestion"
}

variable "use_existing_adls_storage" {
  type        = bool
  default     = false
  description = "Use an existing ADLS Gen2 storage account instead of provisioning new"
}

variable "use_media_describer_azure_cu" {
  type        = bool
  default     = false
  description = "Enable media description with Azure Content Understanding"
}

variable "use_speech_input_browser" {
  type        = bool
  default     = false
  description = "Enable browser-based speech recognition"
}

variable "use_speech_output_browser" {
  type        = bool
  default     = false
  description = "Enable browser-based speech synthesis"
}

variable "use_speech_output_azure" {
  type        = bool
  default     = false
  description = "Enable Azure Speech Service for text-to-speech"
}

variable "enable_language_picker" {
  type        = bool
  default     = false
  description = "Enable language picker in the UI"
}

variable "use_chat_history_browser" {
  type        = bool
  default     = false
  description = "Enable client-side chat history (localStorage)"
}

variable "use_chat_history_cosmos" {
  type        = bool
  default     = false
  description = "Enable server-side chat history with Cosmos DB"
}

variable "use_authentication" {
  type        = bool
  default     = false
  description = "Enable Entra ID authentication"
}

variable "enforce_access_control" {
  type        = bool
  default     = false
  description = "Enable document-level access control via ACLs"
}

variable "disable_app_services_authentication" {
  type        = bool
  default     = false
  description = "Force MSAL app auth instead of built-in App Service auth"
}

variable "enable_global_documents" {
  type        = bool
  default     = false
  description = "Make global documents visible to all users"
}

variable "enable_unauthenticated_access" {
  type        = bool
  default     = false
  description = "Allow unauthenticated access when auth is enabled"
}

variable "use_private_endpoint" {
  type        = bool
  default     = false
  description = "Enable private endpoints for network isolation"
}

variable "use_vpn_gateway" {
  type        = bool
  default     = false
  description = "Deploy VPN Gateway for secure access to private endpoints"
}

variable "use_application_insights" {
  type        = bool
  default     = true
  description = "Enable Application Insights monitoring"
}

variable "use_user_upload" {
  type        = bool
  default     = false
  description = "Enable user document upload feature"
}

variable "use_local_pdf_parser" {
  type        = bool
  default     = false
  description = "Use local PDF parser instead of Document Intelligence"
}

variable "use_local_html_parser" {
  type        = bool
  default     = false
  description = "Use local HTML parser instead of Document Intelligence"
}

variable "use_ai_project" {
  type        = bool
  default     = false
  description = "Deploy Azure AI Foundry project"
}

variable "use_agentic_knowledgebase" {
  type        = bool
  default     = false
  description = "Enable agentic retrieval with knowledge base"
}

variable "use_web_source" {
  type        = bool
  default     = false
  description = "Enable web sources for agentic retrieval"
}

variable "use_sharepoint_source" {
  type        = bool
  default     = false
  description = "Enable SharePoint sources for agentic retrieval"
}
