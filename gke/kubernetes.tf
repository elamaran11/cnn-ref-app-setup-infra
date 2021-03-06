data "google_client_config" "current" {}
data "google_project" "project" {
  # project_id             = data.google_client_config.current.project
}

module "gke" {
  source                 = "terraform-google-modules/kubernetes-engine/google"
  project_id             = var.project_id
  # project_id             = data.google_project.project.project_id
  # project_id             = data.google_client_config.current.project
  region                 = var.region
  zones                  = [var.zone]
  name                   = "${var.resource_prefix}-${var.cluster_name}"
  network                = var.network
  subnetwork             = var.subnetwork
  ip_range_pods          = var.pods_subnet
  ip_range_services      = var.services_subnet
  create_service_account = false
  service_account        = "${data.google_project.project.number}-compute@developer.gserviceaccount.com"
  initial_node_count     = var.gcp_cluster_count
}

provider "kubernetes" {
  load_config_file = false

  host  = "https://${module.gke.endpoint}"
  token = data.google_client_config.current.access_token
  cluster_ca_certificate = base64decode(
    module.gke.ca_certificate
  )
}

resource "kubernetes_namespace" "stage" {
  metadata {
    name = "staging"
  }
}


resource "kubernetes_namespace" "prod" {
  metadata {
    name = "production"
  }
}

