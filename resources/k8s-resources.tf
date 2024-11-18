resource "helm_release" "external_secrets_cluster_store" {
  depends_on = [helm_release.external-secrets, module.gke]
  name       = "external-secrets-cluster-store"
  repository = var.raw_helm_chart.repository
  chart      = var.raw_helm_chart.chart
  version    = var.raw_helm_chart.version
  values = [
    <<-EOF
    resources:
      - apiVersion: external-secrets.io/v1beta1
        kind: ClusterSecretStore
        metadata:
          name: gcp-secret-store
    
        spec:
          provider:
            gcpsm:
               projectID: ${var.project_id}
    EOF
  ]
}


resource "kubernetes_namespace" "apps" {
  metadata {
    annotations = {
      name = var.apps_namespace
    }
    name = var.apps_namespace
  }
  depends_on = [module.gke]
}

resource "helm_release" "applicationset" {
  depends_on = [module.gke, helm_release.argocd]
  name       = "applicationset"
  repository = var.raw_helm_chart.repository
  chart      = var.raw_helm_chart.chart
  version    = var.raw_helm_chart.version
  values = [
    <<-EOF
    resources:
      - apiVersion: argoproj.io/v1alpha1
        kind: ApplicationSet
        metadata:
            name: apps
            namespace: argocd
            
        spec:
          generators:
          - matrix:
              generators:
              - list:
                  elements:
                  - cluster: isolution
                    url: https://kubernetes.default.svc
              - git:
                  files:
                  - path: ${terraform.workspace}/*/kustomization.yaml
                  repoURL: ${var.repo_url}
                  revision: ${var.repo_branch}

          template:
              metadata:
                name: '{{path[1]}}'
                annotations:
                  argocd-image-updater.argoproj.io/image-list: backend=us-central1-docker.pkg.dev/${var.project_id}/isolution-registry/isolution-backend-${terraform.workspace}
                  argocd-image-updater.argoproj.io/backend.update-strategy: latest
                  argocd-image-updater.argoproj.io/annotation.update-strategy: latest
                  argocd-image-updater.argoproj.io/git-branch: main
                  argocd-image-updater.argoproj.io/write-back-method: git
                  argocd-image-updater.argoproj.io/write-back-target: kustomization
                namespace: ${var.apps_namespace}         
              spec:
                destination:
                  namespace: ${var.apps_namespace}
                  server: '{{url}}'
                
                project: default
                source:
                  path: '{{path}}'
                  repoURL: ${var.repo_url}
                  targetRevision: ${var.repo_branch}
                
                syncPolicy:
                  automated:
                    prune: true
    EOF
  ]
}