variable "region" {
  type        = string
  description = "The region to create resources"
  default     = "us-central1"
}

variable "zone" {
  type        = string
  description = "The cluster availability zone"
  default     = "us-central1-c"
}

variable "gcp_cluster_count" {
  type        = number
  description = "Count of cluster instances to start."
  default     = 3
}

variable "resource_prefix" {
  type        = string
  description = "A prefix to assign all resources"
  default     = "cicd-test"
}

variable "cluster_name" {
  type        = string
  description = "Cluster name for the GCP Cluster."
  default     = "dt-kube-demo-cluster"
}

variable "network" {
  type        = string
  description = "The VPC network name to launch the GKE cluster"
  default     = "gke-dev-network"
}

variable "subnetwork" {
  type        = string
  description = "The VPC subnetwork name to launch the GKE cluster"
  default     = "subnet-dev-gke-uscentral1"
}

variable "project_id" {
  type        = string
  description = "The GCP Project for the GKE cluster"
}

variable "services_subnet" {
  type        = string
  description = "The secondary subnetwork name for services"
  default     = "range-2"
}

variable "pods_subnet" {
  type        = string
  description = "The secondary subnetwork name for pods"
  default     = "range-1"
}
