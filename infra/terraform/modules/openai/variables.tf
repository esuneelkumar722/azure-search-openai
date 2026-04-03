variable "name" { type = string }
variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "tags" { type = map(string) }
variable "sku_name" { type = string }
variable "public_network_access" { type = string }
variable "bypass" { type = string }
variable "disable_local_auth" { type = bool }

variable "chatgpt" {
  type = object({
    model_name         = string
    deployment_name    = string
    deployment_version = string
    deployment_sku     = string
    deployment_capacity = number
  })
}

variable "embedding" {
  type = object({
    model_name         = string
    deployment_name    = string
    deployment_version = string
    deployment_sku     = string
    deployment_capacity = number
  })
}

variable "eval" {
  type = object({
    model_name         = string
    deployment_name    = string
    deployment_version = string
    deployment_sku     = string
    deployment_capacity = number
  })
  default = null
}

variable "knowledge_base" {
  type = object({
    model_name         = string
    deployment_name    = string
    deployment_version = string
    deployment_sku     = string
    deployment_capacity = number
  })
  default = null
}
