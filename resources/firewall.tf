/******************************************
	Firewall rules
 *****************************************/
locals {
  subnets_map = module.network.subnets
}

locals {
  pod_ranges = [var.subnets_list[1]["secondary_ip_range"][0]["ip_cidr_range"]]
  rules = [
    for f in var.firewall_rules : {
      name                    = "${terraform.workspace}-${f.name}"
      direction               = f.direction
      priority                = lookup(f, "priority", null)
      description             = lookup(f, "description", null)
      ranges                  = strcontains(f.name, "allow-pod-traffic") ? local.pod_ranges : lookup(f, "ranges", null)
      source_tags             = lookup(f, "source_tags", null)
      source_service_accounts = lookup(f, "source_service_accounts", null)
      target_tags             = lookup(f, "target_tags", null)
      target_service_accounts = lookup(f, "target_service_accounts", null)
      allow                   = lookup(f, "allow", [])
      deny                    = lookup(f, "deny", [])
      log_config              = lookup(f, "log_config", null)
    }
  ]
}

module "vpc_firewall" {
  source       = "../modules/firewall_rules"
  project_id   = var.project_id
  network_name = "${var.common_resource_id}-vpc"
  rules        = local.rules
  depends_on   = [module.gke, module.network]
}
