variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "tags" { type = map(string) }
variable "application_insights_name" { type = string }
variable "log_analytics_name" { type = string }
variable "dashboard_name" { type = string }
variable "public_network_access" { type = string }
