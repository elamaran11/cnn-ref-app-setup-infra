# GKE Cluster Terraform

Set up a simple GKE cluster using the Google Cloud Terraform module

## Required
- terraform >= 12
- Google Cloud SDK
- Google Cloud Account or Service Account credentials
- jq

## Getting Started

1. Authenticate with Google Cloud Project: `gcloud auth login` OR download a Service Account credentials file and set environment variable `GOOGLE_CLOUD_KEYFILE_JSON=/path/to/credetials.json`
2. Run `terraform init -backend-config=environments/demo/backend.demo.tf`
3. Run `terrform plan -var-file=environments/demo/terraform.demo.tfvars`
4. Run `terraform apply -var-file=environments/demo/terraform.demo.tfvars`

## CICD

Commit + Push to `master` branch to trigger automation. Configuration for CICD process is located at `builds/cloudbuild.yaml`
