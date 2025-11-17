data "google_client_config" "default" {}

provider "kubernetes" {
    host                   = google_container_cluster.primary.endpoint
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
    token                  = data.google_client_config.default.access_token
  
}

provider "helm" {
  kubernetes = {
    host = google_container_cluster.primary.endpoint
    cluster_ca_certificate = base64decode(google_container_cluster.primary.master_auth[0].cluster_ca_certificate)
    token = data.google_client_config.default.access_token
  }
}

resource "kubernetes_namespace" "argocd" {
    metadata {
        name = "argocd"
    }
  
}

resource "helm_release" "argocd" {

    depends_on = [ kubernetes_namespace.argocd ]
    name       = "argocd"
    repository = "https://argoproj.github.io/argo-helm"
    chart      = "argo-cd"
    namespace  = kubernetes_namespace.argocd.metadata[0].name
    version    = "5.23.6"
    values = [
        file("${path.module}/argocd-values.yaml")
    ]

    set = [ {
      name = "server.service.type"
      value = "LoadBalancer"
    },
    {
      name = "server.service.loadBalancerIP"
      value = ""
    } ]
}       