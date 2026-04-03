variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "tags" { type = map(string) }
variable "hub_name" { type = string }
variable "project_name" { type = string }
variable "storage_account_id" { type = string }
variable "application_insights_id" {
  type    = string
  default = ""
}
