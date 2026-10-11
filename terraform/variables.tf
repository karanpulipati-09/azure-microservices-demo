variable "azure_subscription_id" {
  type = string
}

variable "azure_tenant_id" {
  type = string
}

variable "azure_client_id" {
  type = string
}

variable "region" {
  type    = string
  default = "eastus"
}

variable "resource_group_name" {
  type    = string
  default = "rg-aks-staging"
}

variable "cluster_name" {
  type    = string
  default = "aks-staging"
}

variable "node_count" {
  type    = number
  default = 3
}

variable "node_vm_size" {
  type    = string
  default = "Standard_D2s_v7"
}

variable "acr_name" {
  type    = string
  default = "aksstagingacr6e4ced83"
}

variable "github_actions_sp_object_id" {
  description = "Object ID of the github-actions-aks service principal — used for the AcrPush role assignment on ACR. Stable across destroy/recreate cycles since the SP (not the ACR) is long-lived."
  type        = string
  default     = "cecb3866-5b93-40cb-9dbe-216a0f39e22d"
}

variable "environment" {
  type    = string
  default = "staging"
}
