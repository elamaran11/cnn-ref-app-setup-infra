#!/bin/bash

export JENKINS_USER=$(cat creds.json | jq -r '.jenkinsUser')
export JENKINS_PASSWORD=$(cat creds.json | jq -r '.jenkinsPassword')
export JENKINS_URL=$(kubectl get service jenkins -n cicd -o=json | jq -r .status.loadBalancer.ingress[].hostname)
export JENKINS_URL_PORT=$(kubectl get service jenkins -n cicd -o=json | jq -r '.spec.ports[] | select(.name=="http") | .port')

echo "--------------------------------------------------------------------------"
echo "Jenkins is running @ : http://$JENKINS_URL:$JENKINS_URL_PORT"
echo "Admin user           : $JENKINS_USER"
echo "Admin password       : $JENKINS_PASSWORD"
echo "--------------------------------------------------------------------------"
echo ""
