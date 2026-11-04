output "acr_login_server" {
  value = azurerm_container_registry.acr.login_server
}
output "aks_cluster_name" {
  value = azurerm_kubernetes_cluster.aks.name
}
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}
output "key_vault_name" {
  value = azurerm_key_vault.kv.name
}
output "api_workload_identity_client_id" {
  value = azurerm_user_assigned_identity.api_workload.client_id
}
output "tenant_id" {
  value = data.azurerm_client_config.current.tenant_id
}
