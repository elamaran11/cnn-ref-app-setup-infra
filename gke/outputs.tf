output "ca_certificate" {
  value = module.gke.ca_certificate
}

output "location" {
  value = module.gke.location
}

output "master_version" {
  value = module.gke.master_version
}

output "name" {
  value = module.gke.name
}

output "cluster_type" {
  value = module.gke.type
}

output "zones" {
  value = module.gke.zones
}

output "region" {
  value = module.gke.region
}
