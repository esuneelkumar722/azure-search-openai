variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "tags" { type = map(string) }
variable "vnet_name" { type = string }
variable "use_vpn_gateway" { type = bool }
variable "vpn_gateway_name" {
  type    = string
  default = ""
}
variable "dns_resolver_name" {
  type    = string
  default = ""
}
