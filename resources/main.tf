# in case ypu will use shared network
module "network" {
  source             = "../modules/core_network"
  project_id         = var.project_id
  project_name       = var.project_id
  region             = var.region
  common_resource_id = var.common_resource_id
  subnets            = var.subnets_list
  nat_external_ips   = var.nat_external_ips
}


module "memorystore" {
  source = "../modules/memorystore"
  name   = "redis-${var.common_resource_id}"

  project_id              = var.project_id
  region                  = var.region
  location_id             = var.zones[0]
  alternative_location_id = var.zones[1]
  secret_id  = "isolution-redis"
  auth_enabled            = false
  transit_encryption_mode = "DISABLED"
  authorized_network      = module.network.vpc_network.self_link
  memory_size_gb          = var.memory_size
  persistence_config = {
    persistence_mode    = "RDB"
    rdb_snapshot_period = "ONE_HOUR"
  }
  labels = {
    maintained_by = "terraform"
  }
  depends_on = [module.network, google_project_service.redis_api]
}

module "gke" {
  source                     = "../modules/gke"
  deletion_protection        = false
  project_id                 = var.project_id
  service_account            = module.gke-sa.email
  enable_private_nodes       = true
  zones                      = var.zones
  network_project_id         = var.project_id
  name                       = var.common_resource_id
  region                     = var.region
  master_ipv4_cidr_block     = var.master_ipv4_cidr_block
  network                    = "${var.common_resource_id}-vpc"
  subnetwork                 = "${var.common_resource_id}-subnet-${var.subnets_list[1].name}"
  ip_range_pods              = var.subnets_list[1]["secondary_ip_range"][0]["range_name"]
  ip_range_services          = var.subnets_list[1]["secondary_ip_range"][1]["range_name"]
  horizontal_pod_autoscaling = var.horizontal_pod_autoscaling
  filestore_csi_driver       = var.filestore_csi_driver
  node_pools                 = var.node_pools
  master_authorized_networks = [{ cidr_block = "154.176.19.108/32", display_name = "Mahmoud public ip" }]
  depends_on                 = [module.gke-sa, module.network, google_project_service.gke]
}

module "mysql" {
  source     = "../modules/mysql"
  project_id = var.project_id
  secret_id  = "isolution-mysql"
  region     = var.region
  tier       = var.mysql_tier
  network_id = module.network.vpc_network.self_link
  user_name  = var.common_resource_id
  database_version = "MYSQL_8_0"
  depends_on = [google_project_service.sqladmin_api]
}
