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
  default = 2
}

variable "node_vm_size" {
  type    = string
  default = "Standard_D2s_v3"
}

variable "acr_name" {
  type    = string
  default = "aksstagingacr49bc2c25"
}

variable "github_actions_sp_object_id" {
  description = "Object ID of the github-actions-aks service principal — used for the AcrPush role assignment on ACR. Stable across destroy/recreate cycles since the SP (not the ACR) is long-lived."
  type        = string
  default     = "71a7a944-31b0-4f68-ab5f-855d891bf692"
}

variable "environment" {
  type    = string
  default = "staging"
}
