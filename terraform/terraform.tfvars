# Azure subscription ID — set via environment variable or terraform.tfvars.local
# azure_subscription_id = "6e4ced83-d303-4f8f-ae15-4cdfad7d271a"

region = "eastus"
resource_group_name = "rg-aks-staging"
cluster_name = "aks-staging"
node_count = 3
node_vm_size = "Standard_D2s_v3"

# ACR name — override with unique name per environment (e.g., via terraform.tfvars.local or TF_VAR_acr_name)
acr_name = "aksstagingacr6e4ced83"
