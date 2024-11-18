variable "region" {
  type        = string
  description = "The region where db should deploy"
  default     = null
}

variable "project_id" {
  type = string
}

variable "network_id" {
  type = string
}

variable "user_name" {
  type        = string
  description = "Username of the DB"
}

variable "secret_id" {
  description = "secret id for secret manager"
  # default = ""
  type = string
}

variable database_version {
  type        = string
  description = "description"
}

variable tier {
  type        = string
  default     = "db-f1-micro"
  description = "description"
}
