#!/bin/bash

# load in the shared library and validate argument
source ./deploymentArgument.lib
DEPLOYMENT=$1
validate_deployment_argument $DEPLOYMENT

export GITHUB_USER_EMAIL=$(cat creds.json | jq -r '.githubUserEmail')
export GITHUB_ORGANIZATION=$(cat creds.json | jq -r '.githubOrg')
export REGISTRY_URL=$(cat creds.json | jq -r '.registry')
export PRIVATE_DOCKER_REPO_FLAG=$(cat creds.json | jq -r '.privateDockerRepoFlag')
echo "----------------------------------------------------"
echo "Deploying Jenkins ..."
rm -f ./manifests/gen/k8s-jenkins-deployment.yml

mkdir -p ./manifests/gen

if [[ $PRIVATE_DOCKER_REPO_FLAG =~ ^[Yy]$ ]]
then 
  kubectl create -f ./manifests/docker-registry/k8s-docker-registry-pvc.yml 
  kubectl create -f ./manifests/docker-registry/k8s-docker-registry-deployment.yml
  kubectl create -f ./manifests/docker-registry/k8s-docker-registry-service.yml  
  REGISTRY_URL=""
  REGISTRY_IP=$(kubectl get service docker-registry -n cicd -o=json | jq -r '.spec.clusterIP | select (.!=null)')
  REGISTRY_PORT=$(kubectl get service docker-registry -n cicd -o=json | jq -r '.spec.ports[] | select (.!=null) | .port')
  REGISTRY_URL=$REGISTRY_IP:$REGISTRY_PORT
  echo $REGISTRY_URL
fi

case $DEPLOYMENT in
  ocp)
    cat ./manifests/jenkins/ocp-jenkins-deployment.yml | \
      sed 's~GITHUB_USER_EMAIL_PLACEHOLDER~'"$GITHUB_USER_EMAIL"'~' | \
      sed 's~GITHUB_ORGANIZATION_PLACEHOLDER~'"$GITHUB_ORGANIZATION"'~' | \
      sed 's~DOCKER_REGISTRY_IP_PLACEHOLDER~'"$REGISTRY_URL"'~' >> ./manifests/gen/ocp-jenkins-deployment.yml
    oc create -f ./manifest/jenkins/ocp-jenkins-pvcs.yml
    oc create -f ./manifests/gen/ocp-jenkins-deployment.yml
    oc create -f ./manifests/jenkins/ocp-jenkins-rbac.yml
    ;;
  *)
    cat ./manifests/jenkins/k8s-jenkins-deployment.yml | \
      sed 's~GITHUB_USER_EMAIL_PLACEHOLDER~'"$GITHUB_USER_EMAIL"'~' | \
      sed 's~GITHUB_ORGANIZATION_PLACEHOLDER~'"$GITHUB_ORGANIZATION"'~' | \
      sed 's~DOCKER_REGISTRY_IP_PLACEHOLDER~'"$REGISTRY_URL"'~' >> ./manifests/gen/k8s-jenkins-deployment.yml
    kubectl create -f ./manifests/jenkins/k8s-jenkins-pvcs.yml 
    kubectl create -f ./manifests/gen/k8s-jenkins-deployment.yml
    kubectl create -f ./manifests/jenkins/k8s-jenkins-rbac.yml
    ;;
esac

echo "----------------------------------------------------"
echo "Letting Jenkins start up [150 seconds] ..."
echo "----------------------------------------------------"
echo ""
sleep 150

# configure DNS.
./configureJenkinsDns.sh
