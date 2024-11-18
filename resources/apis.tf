resource "google_project_service" "artifact_registry" {
  project = var.project_id
  service = "artifactregistry.googleapis.com"
}

resource "google_project_service" "gke" {
  project = var.project_id
  service = "container.googleapis.com"
}

resource "google_project_service" "redis_api" {
  project = var.project_id
  service = "redis.googleapis.com"
}

resource "google_project_service" "filestore_api" {
  project = var.project_id
  service = "file.googleapis.com"
}

resource "google_project_service" "sqladmin_api" {
  project = var.project_id
  service = "sqladmin.googleapis.com"
}