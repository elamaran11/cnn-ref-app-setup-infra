#!/bin/bash

export JENKINS_URL=$(kubectl describe svc jenkins -n cicd | grep "LoadBalancer Ingress:" | sed 's~LoadBalancer Ingress:[ \t]*~~')
export JENKINS_URL_PORT=(cat creds.json | jq -r '.jenkinsPort')

echo "----------------------------------------------------"
echo "Jenkins is running @ : http://$JENKINS_URL:$JENKINS_URL_PORT"
echo "Admin user           : $JENKINS_USER"
echo "Admin password       : $JENKINS_PASSWORD"