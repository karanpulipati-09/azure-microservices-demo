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
  default = "Standard_D2s_v3"
}

variable "acr_name" {
  type    = string
  default = "aksstagingacr6e4ced83"
}

variable "environment" {
  type    = string
  default = "staging"
}
