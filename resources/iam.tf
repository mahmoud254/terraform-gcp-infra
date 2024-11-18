module "service-accounts" {
  source = "../modules/service-accounts"
  depends_on = [
    module.gke
  ]
  for_each              = var.workload_identity_service_account
  project_id            = var.project_id
  names                 = ["${each.key}"]
  current_project_roles = lookup(each.value, "current_project_roles", [])
  # authoritative roles granted *on* the service accounts to other identities
  iam = {
    "roles/iam.workloadIdentityUser" = ["serviceAccount:${var.project_id}.svc.id.goog[${each.value["k8s_namespace"]}/${each.key}]"]
  }
}

module "gke-sa" {
  source     = "../modules/service-accounts"
  project_id = var.project_id
  names      = ["gke-${terraform.workspace}"]
  project_roles = [
    "${var.project_id}=>roles/artifactregistry.reader",
    "${var.project_id}=>roles/logging.logWriter",
    "${var.project_id}=>roles/monitoring.metricWriter",
    "${var.project_id}=>roles/monitoring.viewer",
    "${var.project_id}=>roles/stackdriver.resourceMetadata.writer",
    "${var.project_id}=>roles/storage.objectViewer",
    "${var.project_id}=>roles/artifactregistry.reader",
  ]
}