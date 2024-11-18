resource "google_compute_global_address" "private_ip_address" {

  project       = var.project_id
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = var.network_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = var.network_id
  service                 = "servicenetworking.googleapis.com"
  deletion_policy         = "ABANDON"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_secret_manager_secret" "db-secretmanager" {
  secret_id = var.secret_id
  project   = var.project_id

  replication {
    user_managed {
      replicas {
        location = var.region
      }
    }
  }
  labels = {
    maintained_by = "terraform"
  }
}


resource "google_sql_database" "database" {
  project  = var.project_id
  name     = "${terraform.workspace}-mysql"
  instance = google_sql_database_instance.mysql-instance.name

}

resource "google_sql_database_instance" "mysql-instance" {

  name = "${terraform.workspace}-annotation-mysqldb-instance"

  project             = var.project_id
  region              = var.region
  database_version    = var.database_version
  root_password       = random_password.sql_password.result
  deletion_protection = false


  settings {
    tier = var.tier
    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = var.network_id
      enable_private_path_for_google_cloud_services = true
    }
  }
}

resource "random_password" "sql_password" {
  length           = 7
  special          = true
  override_special = "!#$%&*"
}

resource "google_secret_manager_secret_version" "sql_credentials_secret_version" {

  secret = google_secret_manager_secret.db-secretmanager.name

  secret_data = jsonencode({
    DB_USERNAME          = var.user_name
    DB_PASSWORD          = random_password.sql_password.result
    DB_HOSTNAME          = google_sql_database_instance.mysql-instance.ip_address.0.ip_address
    DB_PORT              = "3306"
  })
}

resource "google_sql_user" "users" {
  project  = var.project_id
  name     = var.user_name
  instance = google_sql_database_instance.mysql-instance.name
  password = random_password.sql_password.result
}
