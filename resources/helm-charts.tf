resource "helm_release" "external-secrets" {
  chart            = var.external_secrets_helm_chart.chart
  name             = var.external_secrets_helm_chart.name
  repository       = var.external_secrets_helm_chart.repository
  namespace        = var.external_secrets_helm_chart.namespace
  version          = var.external_secrets_helm_chart.version
  create_namespace = true

  set {
    name  = "serviceAccount.create"
    value = "true"
  }

  # Connector image updates are not tied to Helm chart updates, so in order to keep the Connector up to date we are using its image sha256 as a Helm property.
  # Every time a new version of the Connector is pushed and the Terraform build runs, the Connector will be updated and restarted.
  set {
    name  = "serviceAccount.name"
    value = "external-secrets"
  }

  set {
    name  = "serviceAccount.annotations.iam\\.gke\\.io/gcp-service-account"
    value = var.external_secrets_sa
  }

  set {
    name  = "installCRDs"
    value = true
  }

  depends_on = [module.gke]
}


resource "helm_release" "nginx-ingress" {
  chart            = var.nginx_helm_chart.chart
  name             = var.nginx_helm_chart.name
  repository       = var.nginx_helm_chart.repository
  namespace        = var.nginx_helm_chart.namespace
  version          = var.nginx_helm_chart.version
  create_namespace = true
  depends_on       = [module.gke]
}


resource "helm_release" "argocd" {
  
  chart            = var.argocd_helm_chart.chart
  name             = var.argocd_helm_chart.name
  repository       = var.argocd_helm_chart.repository
  namespace        = var.argocd_helm_chart.namespace
  version          = var.argocd_helm_chart.version
  create_namespace = true
  set {
    name  = "crds.install"
    value = true
  }
  depends_on = [module.gke]
}

resource "helm_release" "kube-prom-stack" {
  
  chart            = var.kube_prom_stack_helm_chart.chart
  name             = var.kube_prom_stack_helm_chart.name
  repository       = var.kube_prom_stack_helm_chart.repository
  namespace        = var.kube_prom_stack_helm_chart.namespace
  version          = var.kube_prom_stack_helm_chart.version
  create_namespace = true
  set {
    name  = "crds.enabled"
    value = true
  }
  depends_on = [module.gke]
}