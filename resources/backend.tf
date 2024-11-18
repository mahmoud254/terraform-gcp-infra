terraform {
  backend "gcs" {
    bucket = "isolution-terraform-state-bucket"
    prefix = "resources.tfstate"
  }
}
