#!/bin/bash

# load in the shared library and validate argument
source ./deploymentArgument.lib
DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

CREDS=./creds.json

if [ -f "$CREDS" ]
then
    DEPLOYMENT=$(cat creds.json | jq -r '.deployment | select (.!=null)')
    if [ -n $DEPLOYMENT ]
    then 
      DEPLOYMENT=$1
    fi
    GITHUB_PERSONAL_ACCESS_TOKEN=$(cat creds.json | jq -r '.githubPersonalAccessToken')
    GITHUB_USER_NAME=$(cat creds.json | jq -r '.githubUserName')
    GITHUB_USER_EMAIL=$(cat creds.json | jq -r '.githubUserEmail')
    GITHUB_ORGANIZATION=$(cat creds.json | jq -r '.githubOrg')
    RESOURCE_PREFIX=$(cat creds.json | jq -r '.resourcePrefix')

    CLUSTER_ZONE=$(cat creds.json | jq -r '.clusterZone')
    CLUSTER_REGION=$(cat creds.json | jq -r '.clusterRegion')

    AZURE_SUBSCRIPTION=$(cat creds.json | jq -r '.azureSubscription')
    AZURE_LOCATION=$(cat creds.json | jq -r '.azureLocation')

    GKE_PROJECT=$(cat creds.json | jq -r '.gkeProject')
    PRIVATE_DOCKER_REPO_FLAG=$(cat creds.json | jq -r '.privateDockerRepoFlag')

fi

clear
echo "==================================================================="
echo "Please enter the values for provider: $DEPLOYMENT_NAME"
echo "Press <enter> to keep the current value"
echo "==================================================================="
read -p "GitHub User Name                       (current: $GITHUB_USER_NAME) : " GITHUB_USER_NAME_NEW
read -p "GitHub Personal Access Token           (current: $GITHUB_PERSONAL_ACCESS_TOKEN) : " GITHUB_PERSONAL_ACCESS_TOKEN_NEW
read -p "GitHub User Email                      (current: $GITHUB_USER_EMAIL) : " GITHUB_USER_EMAIL_NEW
read -p "GitHub Organization                    (current: $GITHUB_ORGANIZATION) : " GITHUB_ORGANIZATION_NEW
read -p "PaaS Resource Prefix (e.g. lastname)   (current: $RESOURCE_PREFIX) : " RESOURCE_PREFIX_NEW

case $DEPLOYMENT in
  eks)
    read -p "Cluster Region (eg.us-east-1)          (current: $CLUSTER_REGION) : " CLUSTER_REGION_NEW
    ;;
  aks)
    read -p "Azure Subscription ID                  (current: $AZURE_SUBSCRIPTION) : " AZURE_SUBSCRIPTION_NEW
    read -p "Azure Location (e.g. eastus)           (current: $AZURE_LOCATION) : " AZURE_LOCATION_NEW
    ;;
  gke)
    read -p "Google Project                         (current: $GKE_PROJECT) : " GKE_PROJECT_NEW
    read -p "Cluster Zone (eg.us-east1-b)           (current: $CLUSTER_ZONE) : " CLUSTER_ZONE_NEW
    read -p "Cluster Region (eg.us-east1)           (current: $CLUSTER_REGION) : " CLUSTER_REGION_NEW
    ;;
  ocp)
    ;;
esac
read -p "Private Docker Repo (Y/N) : " PRIVATE_DOCKER_REPO_NEW
echo "==================================================================="
echo ""
# set value to new input or default to current value
GITHUB_USER_NAME=${GITHUB_USER_NAME_NEW:-$GITHUB_USER_NAME}
GITHUB_PERSONAL_ACCESS_TOKEN=${GITHUB_PERSONAL_ACCESS_TOKEN_NEW:-$GITHUB_PERSONAL_ACCESS_TOKEN}
GITHUB_USER_EMAIL=${GITHUB_USER_EMAIL_NEW:-$GITHUB_USER_EMAIL}
GITHUB_ORGANIZATION=${GITHUB_ORGANIZATION_NEW:-$GITHUB_ORGANIZATION}
CLUSTER_REGION=${CLUSTER_REGION_NEW:-$CLUSTER_REGION}
# aks specific
AZURE_SUBSCRIPTION=${AZURE_SUBSCRIPTION_NEW:-$AZURE_SUBSCRIPTION}
AZURE_LOCATION=${AZURE_LOCATION_NEW:-$AZURE_LOCATION}
RESOURCE_PREFIX=${RESOURCE_PREFIX_NEW:-$RESOURCE_PREFIX}
# gke specific
GKE_PROJECT=${GKE_PROJECT_NEW:-$GKE_PROJECT}
CLUSTER_ZONE=${CLUSTER_ZONE_NEW:-$CLUSTER_ZONE}
PRIVATE_DOCKER_REPO=${PRIVATE_DOCKER_REPO_NEW:-$PRIVATE_DOCKER_REPO}

echo -e "Please confirm all are correct:"
echo ""
echo "GitHub User Name             : $GITHUB_USER_NAME"
echo "GitHub Personal Access Token : $GITHUB_PERSONAL_ACCESS_TOKEN"
echo "GitHub User Email            : $GITHUB_USER_EMAIL"
echo "GitHub Organization          : $GITHUB_ORGANIZATION" 
echo "PaaS Resource Prefix         : $RESOURCE_PREFIX"

case $DEPLOYMENT in
  eks)
    echo "Cluster Region               : $CLUSTER_REGION"
    ;;
  aks)
    echo "Azure Subscription           : $AZURE_SUBSCRIPTION"
    echo "Azure Location               : $AZURE_LOCATION"
    ;;
  gke)
    echo "Google Project               : $GKE_PROJECT"
    echo "Cluster Region               : $CLUSTER_REGION"
    echo "Cluster Zone                 : $CLUSTER_ZONE"
    ;;
  ocp)
    ;;
esac
echo "Private Docker Repo Flag      : $PRIVATE_DOCKER_REPO"
echo "==================================================================="
read -p "Is this all correct? (y/n) : " -n 1 -r
echo ""
echo "==================================================================="

if [[ $REPLY =~ ^[Yy]$ ]]
then
    echo "Making a backup $CREDS to $CREDS.bak"
    cp $CREDS $CREDS.bak 2> /dev/null
    rm $CREDS 2> /dev/null

    cat ./creds.sav | \
      sed 's~DEPLOYMENT_PLACEHOLDER~'"$DEPLOYMENT"'~' | \
      sed 's~GITHUB_USER_NAME_PLACEHOLDER~'"$GITHUB_USER_NAME"'~' | \
      sed 's~PERSONAL_ACCESS_TOKEN_PLACEHOLDER~'"$GITHUB_PERSONAL_ACCESS_TOKEN"'~' | \
      sed 's~GITHUB_USER_EMAIL_PLACEHOLDER~'"$GITHUB_USER_EMAIL"'~' | \
      sed 's~GITHUB_ORG_PLACEHOLDER~'"$GITHUB_ORGANIZATION"'~' | \
      sed 's~PRIVATE_DOCKER_REPO_PLACEHOLDER~'"$PRIVATE_DOCKER_REPO"'~' | \
      sed 's~RESOURCE_PREFIX_PLACEHOLDER~'"$RESOURCE_PREFIX"'~' > $CREDS

    case $DEPLOYMENT in
      eks)
        cp $CREDS $CREDS.temp
        cat $CREDS.temp | \
          sed 's~CLUSTER_REGION_PLACEHOLDER~'"$CLUSTER_REGION"'~' > $CREDS
        rm $CREDS.temp 2> /dev/null
        ;;
      aks)
        cp $CREDS $CREDS.temp
        cat $CREDS.temp | \
          sed 's~AZURE_SUBSCRIPTION_PLACEHOLDER~'"$AZURE_SUBSCRIPTION"'~' | \
          sed 's~AZURE_LOCATION_PLACEHOLDER~'"$AZURE_LOCATION"'~' > $CREDS
        rm $CREDS.temp 2> /dev/null
        ;;
      gke)
        cp $CREDS $CREDS.temp
        cat $CREDS.temp | \
          sed 's~GKE_PROJECT_PLACEHOLDER~'"$GKE_PROJECT"'~' | \
          sed 's~CLUSTER_REGION_PLACEHOLDER~'"$CLUSTER_REGION"'~' | \
          sed 's~CLUSTER_ZONE_PLACEHOLDER~'"$CLUSTER_ZONE"'~' > $CREDS
        rm $CREDS.temp 2> /dev/null
        ;;
      ocp)
        ;;
    esac
    echo ""
    echo "The updated credentials file can be found here: $CREDS"
    echo ""
fi