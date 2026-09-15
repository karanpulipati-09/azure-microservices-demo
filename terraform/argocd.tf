# ArgoCD — GitOps controller, watches Git repo and syncs Helm charts to cluster
resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  namespace        = "argocd"
  create_namespace = true
  version          = "7.4.4"

  set {
    name  = "server.service.type"
    value = "ClusterIP"
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}
