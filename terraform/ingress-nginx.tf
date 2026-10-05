# ingress-nginx — installed into the cluster automatically on every fresh apply.
# frontend already proxies /api/* internally to the api service in its own
# namespace (apps/frontend/default.conf), so a single entry point via the
# frontend Ingress is sufficient — no cross-namespace Ingress routing needed.
resource "helm_release" "ingress_nginx" {
  name             = "ingress-nginx"
  repository       = "https://kubernetes.github.io/ingress-nginx"
  chart            = "ingress-nginx"
  namespace        = "ingress-nginx"
  create_namespace = true
  version          = "4.11.3"

  set {
    name  = "controller.service.type"
    value = "LoadBalancer"
  }

  depends_on = [azurerm_kubernetes_cluster.aks]
}
