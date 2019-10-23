#!/bin/bash

# values read in from creds file
RESOURCE_PREFIX=$(cat creds.json | jq -r '.resourcePrefix')
GKE_PROJECT=$(cat creds.json | jq -r '.gkeProject')
CLUSTER_ZONE=$(cat creds.json | jq -r '.clusterZone')
CLUSTER_NAME="$RESOURCE_PREFIX"-dt-kube-demo-cluster
<<<<<<< HEAD
NETWORK_NAME=gcp-dev-network
=======
NETWORK_NAME=gke-dev-network
SUBNET_NAME=subnet-dev-gke-uscentral1
>>>>>>> 91ae116bb4a725a70b96193bdb4f31e925d22b8e

echo "===================================================="
echo "About to provision GCP Resources. "
echo "The provisioning will take several minutes"
echo "Cluster Name         : $CLUSTER_NAME"
echo "Cluster Zone         : $CLUSTER_ZONE"
echo "===================================================="
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n' -n1 key
echo ""

echo "------------------------------------------------------"
echo "Creating GKE Cluster: $CLUSTER_NAME"
echo "------------------------------------------------------"
# gcloud container clusters create $CLUSTER_NAME \
#   --project=$GKE_PROJECT \
#   --machine-type n1-standard-2 \
#   --num-nodes 3 \
#   --zone $CLUSTER_ZONE \
#   --cluster-version latest \
#   --enable-cloud-logging \
#   --enable-cloud-monitoring \
#   --subnetwork default

gcloud container clusters create $CLUSTER_NAME \
  --project $GKE_PROJECT \
  --machine-type n1-standard-2 \
  --num-nodes 3 \
  --zone=$CLUSTER_ZONE \
  --cluster-version latest \
<<<<<<< HEAD
  --network $NETWORK_NAME \
  --subnetwork subnet-dev-gke-uscentral1 \
  --cluster-secondary-range-name range-1 \
  --services-secondary-range-name range-2 \
=======
  --enable-cloud-logging \
  --enable-cloud-monitoring \
  --network $NETWORK_NAME \
  --subnetwork subnet-dev-gke-uscentral1 \
  --services-secondary-range-name range-1 \
>>>>>>> 91ae116bb4a725a70b96193bdb4f31e925d22b8e
  --enable-ip-alias

echo "------------------------------------------------------"
echo "Getting Cluster Credentials"
echo "------------------------------------------------------"
gcloud container clusters get-credentials $CLUSTER_NAME
echo "------------------------------------------------------"
echo "account permissions to perform administrative actions"
echo "------------------------------------------------------"
kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user $(gcloud config get-value account)

