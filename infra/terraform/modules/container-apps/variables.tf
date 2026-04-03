variable "resource_group_name" { type = string }
variable "location" { type = string }
variable "tags" { type = map(string) }

# Container Apps Environment
variable "environment_name" { type = string }
variable "log_analytics_workspace_name" { type = string }
variable "log_analytics_workspace_id" { type = string }
variable "subnet_resource_id" {
  type    = string
  default = ""
}
variable "use_private_ingress" {
  type    = bool
  default = false
}
variable "workload_profile" {
  type    = string
  default = "Consumption"
}

# Container Registry
variable "registry_name" { type = string }

# Container App
variable "app_name" { type = string }
variable "identity_id" { type = string }
variable "identity_client_id" { type = string }
variable "target_port" { type = number }
variable "cpu" { type = string }
variable "memory" { type = string }
variable "min_replicas" {
  type    = number
  default = 0
}
variable "allowed_origins" {
  type    = list(string)
  default = []
}

variable "env_variables" {
  type    = map(string)
  default = {}
}

variable "secrets" {
  type      = map(string)
  default   = {}
  sensitive = true
}

variable "env_secrets" {
  type = list(object({
    name       = string
    secret_ref = string
  }))
  default = []
}
