variable "resource_group_id" { type = string }
variable "principal_id" { type = string }
variable "principal_type" { type = string }
variable "backend_principal_id" { type = string }

# Resource IDs for scoping
variable "openai_id" { type = string }
variable "search_id" { type = string }
variable "storage_id" { type = string }
variable "search_principal_id" { type = string }

# Feature flags
variable "deploy_azure_openai" { type = bool }
variable "is_azure_openai_host" { type = bool }
variable "search_service_sku_name" { type = string }
variable "use_multimodal" { type = bool }
variable "use_user_upload" { type = bool }
variable "use_authentication" { type = bool }
variable "use_chat_history_cosmos" { type = bool }
variable "use_integrated_vectorization" { type = bool }
variable "use_cloud_ingestion" { type = bool }
variable "use_cloud_ingestion_acls" { type = bool }
variable "use_speech_output_azure" { type = bool }

# Optional resource references
variable "vision_id" {
  type    = string
  default = ""
}
variable "cosmosdb_account_name" {
  type    = string
  default = ""
}
variable "cosmosdb_id" {
  type    = string
  default = ""
}
variable "user_storage_id" {
  type    = string
  default = ""
}
variable "functions_principal_id" {
  type    = string
  default = ""
}
variable "client_app_id" {
  type    = string
  default = ""
}
