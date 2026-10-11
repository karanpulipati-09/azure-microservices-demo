# Azure subscription ID — set via environment variable or terraform.tfvars.local
# azure_subscription_id = "49bc2c25-d9dc-4928-ae98-4f287f07e8e8"

region = "eastus"
resource_group_name = "rg-aks-staging"
cluster_name = "aks-staging"
node_count = 2
node_vm_size = "Standard_D2s_v3"

# ACR name — override with unique name per environment (e.g., via terraform.tfvars.local or TF_VAR_acr_name)
acr_name = "aksstagingacr49bc2c25"
