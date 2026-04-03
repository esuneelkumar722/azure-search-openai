variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "tags" { type = map(string) }
variable "document_extractor_name" { type = string }
variable "figure_processor_name" { type = string }
variable "text_processor_name" { type = string }
variable "application_insights_name" { type = string }
variable "app_env_variables" {
  type    = map(string)
  default = {}
}
