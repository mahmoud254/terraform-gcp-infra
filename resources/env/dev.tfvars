project_id         = "isolution-442111"
common_resource_id = "isolution-dev"
region             = "us-central1"
zones              = ["us-central1-a", "us-central1-b"]
subnets_list = [
  {
    name      = "public-1"
    cidr      = "172.22.20.0/22"
    region    = "us-central1"
    allow_nat = "true"
    secondary_ip_range = [
      {
        range_name    = "isolution-pods-dev-pub-1"
        ip_cidr_range = "10.12.0.0/21"
      },
      {
        range_name    = "isolution-svc-dev-pub-1"
        ip_cidr_range = "10.11.0.0/24"
      }
    ]

  },
  {
    name      = "private-1"
    cidr      = "172.22.24.0/22"
    region    = "us-central1"
    allow_nat = true
    secondary_ip_range = [
      {
        range_name    = "isolution-pods-dev-private-1"
        ip_cidr_range = "10.220.0.0/21"
      },
      {
        range_name    = "isolution-svc-dev-private-1"
        ip_cidr_range = "10.210.0.0/24"
      }
    ]

  },
]

nat_external_ips = [
  {
    name        = "data-ext-nat-ip-1"
    description = "permanent nat external ip"
    region      = "us-central1"
  },
]

# gke vars
horizontal_pod_autoscaling = true
filestore_csi_driver       = true
workload_identity_service_account = {
  external-secrets = {        #GSA name but It should also match with KSA name
    current_project_roles : [ #GSA Roles at project level
      "roles/secretmanager.secretAccessor"
    ],
    k8s_namespace = "external-secrets" #KSA Namespace Name
  },
    argocd-image-updater = {        #GSA name but It should also match with KSA name
    current_project_roles : [ #GSA Roles at project level
      "roles/artifactregistry.repoAdmin"
    ],
    k8s_namespace = "argocd" #KSA Namespace Name
  }
}

node_pools = [
  {
    name            = "dev-node-pool"
    machine_type    = "e2-standard-2"
    min_count       = 1
    max_count       = 2
    local_ssd_count = 0
    spot            = false
    disk_size_gb    = 50
    disk_type       = "pd-standard"
    image_type      = "COS_CONTAINERD"
    enable_gcfs     = false
    enable_gvnic    = false
    logging_variant = "DEFAULT"
    auto_repair     = true
    auto_upgrade    = true
    # service_account           = "project-service-account@<PROJECT ID>.iam.gserviceaccount.com"
    preemptible        = false
    initial_node_count = 1
    max_pods_per_node  = 100
  }
]

master_ipv4_cidr_block = "10.200.158.0/28"
firewall_rules = [{
  name        = "allow-pod-traffic"
  description = "Allow Pod to Pod connectivity"
  direction   = "INGRESS"
  allow = [{
    protocol = "tcp"
    ports    = ["0-65535"]
  }]
  },
]

memory_size = 1
secret_id = "isolution-dev-psql-secret"

external_secrets_sa = "external-secrets@isolution-442111.iam.gserviceaccount.com"
external_secrets_helm_chart = {
  chart      = "external-secrets"
  name       = "external-secrets"
  repository = "https://charts.external-secrets.io"
  namespace  = "external-secrets"
  version    = "0.9.13"
}
nginx_helm_chart = {
  chart      = "ingress-nginx"
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  namespace  = "ingress-nginx"
  version    = "4.10.0"
}
argocd_helm_chart={
  chart            = "argo-cd"
  name             = "argo-cd"
  repository       = "https://argoproj.github.io/argo-helm"
  namespace        = "argocd"
  version          = "7.3.10"
}

kube_prom_stack_helm_chart={
  chart            = "kube-prometheus-stack"
  name             = "kube-prometheus-stack"
  repository       = "https://prometheus-community.github.io/helm-charts"
  namespace        = "monitoring"
  version          = "66.2.1"
}

raw_helm_chart = {
  chart      = "raw"
  repository = "https://bedag.github.io/helm-charts/"
  version    = "2.0.0"
}

apps_namespace="apps"

repo_url       = "https://github.com/mahmoud254/argocd-k8s-deployment.git"
repo_branch    = "main"
mysql_tier="db-f1-micro"
