
variable "project_id" {
  type        = string
  default     = ""
  description = "description"
}

variable "common_resource_id" {
  type        = string
  default     = "shared"
  description = "description"
}

variable "subnets_list" {
  type = list(object({
    name      = string
    cidr      = string
    region    = optional(string)
    allow_nat = optional(bool)
    secondary_ip_range = optional(list(object({ range_name = string
      ip_cidr_range = string
    })))
  }))
  default     = []
  description = "List of subnet objects"
}

variable "nat_external_ips" {
  type = list(object({
    name        = string
    description = string
    region      = string
  }))
  default = []
}

variable "region" {
  type = string

}


variable "zones" {
  type        = list(string)
  description = "description"
}

variable "firewall_rules" {
  description = "List of custom rule definitions (refer to variables file for syntax)."
  default     = []
  type        = any
}



variable "memory_size" {
  type = number
}


variable "horizontal_pod_autoscaling" {
  type        = bool
  default     = true
  description = "description"
}

variable "filestore_csi_driver" {
  type        = bool
  default     = false
  description = "description"
}

variable "node_pools" {
  type        = list(map(any))
  description = "List of maps containing node pools"

  default = [
    {
      name = "default-node-pool"
    },
  ]
}

variable "master_ipv4_cidr_block" {
  type = string
}


variable "workload_identity_service_account" {
  type = map(object({
    current_project_roles = list(string),
    k8s_namespace         = string
  }))
  default = {}
}


variable "external_secrets_sa" {
  type        = string
  description = "description"
}


variable "nginx_helm_chart" {
  type = object({
    chart      = string
    name       = string
    repository = string
    namespace  = string
    version    = string
  })
}

variable "external_secrets_helm_chart" {
  type = object({
    chart      = string
    name       = string
    repository = string
    namespace  = string
    version    = string
  })
}

variable "argocd_helm_chart" {
  type = object({
    chart      = string
    name       = string
    repository = string
    namespace  = string
    version    = string
  })
}

variable "kube_prom_stack_helm_chart" {
  type = object({
    chart      = string
    name       = string
    repository = string
    namespace  = string
    version    = string
  })
}

variable "raw_helm_chart" {
  type = object({
    chart      = string
    repository = string
    version    = string
  })
}

variable "apps_namespace" {
  type        = string
  description = "description"
}
variable "repo_url" {
  type        = string
  description = "description"
}

variable "repo_branch" {
  type        = string
  description = "description"
}


variable mysql_tier {
  type        = string
  description = "description"
}

