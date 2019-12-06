terraform {
  backend "gcs" {
    bucket = "reference-app-terraform-state"
    prefix = "state/demo/gke"
  }
}
