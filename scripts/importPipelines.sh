LOG_LOCATION=./logs
exec > >(tee -i $LOG_LOCATION/importPipelines.log)
exec 2>&1

YLW='\033[1;33m'
NC='\033[0m'

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

HTTP_RESPONSE=`curl -s -o /dev/null -I -w "%{http_code}" https://github.com/$ORG`

if [ $HTTP_RESPONSE -ne 200 ]
then
    echo "GitHub organization doesn't exist - https://github.com/$ORG - HTTP status code $HTTP_RESPONSE"
    exit 1
fi

export JENKINS_USER=$(cat creds.json | jq -r '.jenkinsUser')
export JENKINS_PASSWORD=$(cat creds.json | jq -r '.jenkinsPassword')
export JENKINS_URL=$(kubectl get service jenkins -n cicd -o=json | jq -r .status.loadBalancer.ingress[].hostname)
export JENKINS_URL_PORT=$(kubectl get service jenkins -n cicd -o=json | jq -r '.spec.ports[] | select(.name=="http") | .port')

# clean up generated file.  dont delete the README!
rm -f ../pipelines/gen/*.xml
rm -f ../pipelines/gen/*.bak

# copy the job templates to gen folder
cp ../pipelines/deploy*.xml ../pipelines/gen/
cp ../pipelines/prod*.xml ../pipelines/gen/

# have an optional argument for importing build pipelines. 
if [ $2 = "build" ]
then
  cp ../pipelines/build*.xml ../pipelines/gen/
  JOBLIST="build-order-service build-catalog-service build-customer-service build-front-end deploy-service deploy-staging deploy-production load-test"
else
  JOBLIST="deploy-staging deploy-production deploy-service load-test"
fi

# loop through a list of jobs and create them.  if already exists, delete it first
echo 'Using GitHub Org as source of Jenkinsfiles : '$ORG
echo 'Jenkins Server                             : 'http://$JENKINS_URL:$JENKINS_URL_PORT

OSTYPE=$(uname -s)
for JOB_NAME in $JOBLIST; do

  # update each copy of the job template file in gen folder with GIT org name
  # NOTE: Mac requires the name of backup file as an argument, Linux does not
  if [ $OSTYPE = "Darwin" ]; then
    sed -i .bak s/ORG_PLACEHOLDER/$ORG/g ../pipelines/gen/$JOB_NAME.xml
  else
    sed -i s/ORG_PLACEHOLDER/$ORG/g ../pipelines/gen/$JOB_NAME.xml
  fi

  # determine if need to delete job first
  status_code=$(curl --write-out %{http_code} --silent --output /dev/null http://$JENKINS_URL:$JENKINS_URL_PORT/job/$JOB_NAME/config.xml -u $JENKINS_USER:$JENKINS_PASSWORD)
  if [[ "$status_code" -eq 200 ]] ; then
    echo Removing existing job $JOB_NAME ...
    curl -s -XPOST http://$JENKINS_URL:$JENKINS_URL_PORT/job/$JOB_NAME/doDelete -u $JENKINS_USER:$JENKINS_PASSWORD -H "Content-Type:text/xml"
  fi

  # add the job
  echo Creating job $JOB_NAME ...
  curl -s -XPOST http://$JENKINS_URL:$JENKINS_URL_PORT/createItem?name=$JOB_NAME --user $JENKINS_USER:$JENKINS_PASSWORD --data-binary @../pipelines/gen/$JOB_NAME.xml -H "Content-Type:text/xml"
done
