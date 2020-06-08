#!/bin/bash
# Ela
RESOURCE_PREFIX=$(cat creds.json | jq -r '.resourcePrefix')
AZURE_LOCATION=$(cat creds.json | jq -r '.azureLocation')
export PRIVATE_DOCKER_REPO_FLAG=$(cat creds.json | jq -r '.privateDockerRepoFlag')
export REGISTRY_URL=$(cat creds.json | jq -r '.registry')
DEPLOYMENT=$(cat creds.json | jq -r '.deployment')
# Ela - Removed all reference to "HTTP:// and placed all JENKINS URL in double quotes"
# Ela
if [ -z $1 ]
then
    echo "Please provide the target GitHub organization as parameter:"
    echo ""
    echo "  e.g.: ./importPipelines.sh <lastname>-dt-kube-demo"
    echo ""
    exit 1
else
    ORG=$1
fi

HTTP_RESPONSE=`curl -s -o /dev/null -I -w "%{http_code}" https://github.com//$ORG`

if [ $HTTP_RESPONSE -ne 200 ]
then
    echo "Bitbucket organization doesn't exist - https://github.com//$ORG - HTTP status code $HTTP_RESPONSE"
    exit 1
fi

export JENKINS_USER=$(cat creds.json | jq -r '.jenkinsUser')
export JENKINS_PASSWORD=$(cat creds.json | jq -r '.jenkinsPassword')
export JENKINS_URL_PORT=$(kubectl get service jenkins -n cicd -o=json | jq -r '.spec.ports[] | select(.name=="http") | .port')
# Ela
case $DEPLOYMENT in
  aks)
    JENKINS_URL="jenkins-$RESOURCE_PREFIX-dt-kube-demo.$AZURE_LOCATION.cloudapp.azure.com"
    ;;
  eks)
    JENKINS_URL=$(kubectl get service jenkins -n cicd -o=json | jq -r '.status.loadBalancer.ingress[].hostname | select (.!=null)')
    ;;
  gke)
   JENKINS_URL=$(kubectl get service jenkins -n cicd -o=json | jq -r '.status.loadBalancer.ingress[].ip | select (.!=null)') 
   ;;
esac

#if [ -n "JENKINS_URL" ]
#then
#  JENKINS_URL=$(kubectl get service jenkins -n cicd -o=json | jq -r '.status.loadBalancer.ingress[].ip')
#fi

# clean up generated file.  dont delete the README!
rm -f ./pipelines/gen/*.xml
rm -f ./pipelines/gen/*.bak

# copy the job templates to gen folder
cp ./pipelines/deploy*.xml ./pipelines/gen/
cp ./pipelines/load*.xml ./pipelines/gen/

# have an optional argument for importing build pipelines. 
if [ $2 == "build" ]
then
  cp ./pipelines/build*.xml ./pipelines/gen/
  JOBLIST="build-order-service build-catalog-service build-customer-service build-payment-service build-front-end deploy-service deploy-staging deploy-production load-test"
else
  JOBLIST="deploy-staging deploy-production deploy-service load-test"
fi

echo "----------------------------------------------------"
echo "Creating Pipleine Jobs in Jenkins"
echo "Source of Jenkinsfiles : http://github.com/$ORG"
echo "Jenkins Server         : http://$JENKINS_URL:$JENKINS_URL_PORT"
echo "Job list to process    : $JOBLIST"
echo "----------------------------------------------------"
if [[ $PRIVATE_DOCKER_REPO_FLAG =~ ^[Yy]$ ]]
then  
  REGISTRY_URL=""
  REGISTRY_IP=$(kubectl get service docker-registry -n cicd -o=json | jq -r '.spec.clusterIP | select (.!=null)')
  REGISTRY_PORT=$(kubectl get service docker-registry -n cicd -o=json | jq -r '.spec.ports[] | select (.!=null) | .port')
  REGISTRY_URL=$REGISTRY_IP:$REGISTRY_PORT
  echo $REGISTRY_URL
fi
# loop through a list of jobs and create them.  if already exists, delete it first
OSTYPE=$(uname -s)
for JOB_NAME in $JOBLIST; do

  # update each copy of the job template file in gen folder with GIT org name
  # NOTE: Mac requires the name of backup file as an argument, Linux does not
  if [ $OSTYPE = "Darwin" ]; then
    sed -i .bak s/ORG_PLACEHOLDER/$ORG/g ./pipelines/gen/$JOB_NAME.xml
    sed -i .bak s/DOCKER_REGISTRY/$REGISTRY_URL/g ./pipelines/gen/$JOB_NAME.xml
  else
    sed -i s/ORG_PLACEHOLDER/$ORG/g ./pipelines/gen/$JOB_NAME.xml
    sed -i s/DOCKER_REGISTRY/$REGISTRY_URL/g ./pipelines/gen/$JOB_NAME.xml
  fi

  # determine if need to delete job first
  status_code=$(curl --write-out %{http_code} --silent --output /dev/null http://$JENKINS_URL:$JENKINS_URL_PORT/job/$JOB_NAME/config.xml -u $JENKINS_USER:$JENKINS_PASSWORD)
  if [[ "$status_code" -eq 200 ]] ; then
    echo Removing existing job $JOB_NAME ...
    curl -s -XPOST "$JENKINS_URL:$JENKINS_URL_PORT/job/$JOB_NAME/doDelete" -u $JENKINS_USER:$JENKINS_PASSWORD -H "Content-Type:text/xml"
  fi

  # add the job
  echo Creating job $JOB_NAME ...
  #Ela
  curl -s -XPOST "$JENKINS_URL:$JENKINS_URL_PORT/createItem?name=$JOB_NAME" --user $JENKINS_USER:$JENKINS_PASSWORD --data-binary @./pipelines/gen/$JOB_NAME.xml -H "Content-Type:text/xml"
  #Ela
done
