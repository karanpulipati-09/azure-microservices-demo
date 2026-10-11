resource "azurerm_container_registry" "acr" {
  name                = var.acr_name
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = "Standard"
  admin_enabled       = false
  tags                = local.tags
}

resource "azurerm_role_assignment" "aks_acr_pull" {
  scope              = azurerm_container_registry.acr.id
  role_definition_name = "AcrPull"
  principal_id       = azurerm_kubernetes_cluster.aks.kubelet_identity[0].object_id
}

# GitHub Actions (OIDC) needs push access to build+push images in CI.
# Previously granted by hand after every destroy/recreate — scoped to the ACR
# resource, so it died with the resource group each time. Managing it here
# means it's recreated automatically on every apply, same as aks_acr_pull above.
resource "azurerm_role_assignment" "gha_acr_push" {
  scope                = azurerm_container_registry.acr.id
  role_definition_name = "AcrPush"
  principal_id         = var.github_actions_sp_object_id
}
