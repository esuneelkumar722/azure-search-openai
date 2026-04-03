variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "tags" { type = map(string) }
variable "resource_token" { type = string }
variable "vnet_name" { type = string }
variable "vnet_subnet_id" { type = string }
variable "application_insights_id" { type = string }
variable "log_analytics_workspace_id" { type = string }

variable "private_endpoint_connections" {
  type = list(object({
    group_id      = string
    dns_zone_name = string
    resource_ids  = list(string)
  }))
}
