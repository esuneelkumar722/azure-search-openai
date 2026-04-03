variable "name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "tags" { type = map(string) }
variable "sku_name" { type = string }
variable "semantic_search" { type = string }
variable "public_network_access" { type = string }
variable "log_analytics_workspace_id" { type = string }
variable "use_application_insights" { type = bool }
variable "shared_private_link_storage_accounts" {
  type    = list(string)
  default = []
}
