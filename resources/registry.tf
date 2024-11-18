resource "google_artifact_registry_repository" "docker-images" {
  repository_id = "isolution-registry"
  project       = var.project_id
  format        = "DOCKER"
  location      = var.region
  depends_on    = [google_project_service.artifact_registry]
  labels = {
    maintained_by = "terraform"
  }
}