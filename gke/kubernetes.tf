data "google_project" "project" {}

module "gke" {
  source                 = "terraform-google-modules/kubernetes-engine/google"
  project_id             = var.project_id
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

