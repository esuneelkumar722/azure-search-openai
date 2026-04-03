variable "name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "tags" { type = map(string) }
variable "sku_name" { type = string }
variable "public_network_access" { type = string }
variable "bypass" { type = string }
variable "is_hns_enabled" {
  type    = bool
  default = false
}
variable "containers" {
  type    = list(string)
  default = []
}
