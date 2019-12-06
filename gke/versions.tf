terraform {
  required_version = ">= 0.12, <= 0.12.17"
  backend "local" {}
}

provider "google" {
  version = "~> 2.18"
  region  = var.region
  project = var.project_id
}

provider "google-beta" {
  version = "~> 3.1"
  region  = var.region
  project = var.project_id
}

