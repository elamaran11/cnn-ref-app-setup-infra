#!/bin/bash
# Adjusted to accomodate OpenShift Container Platform

LOG_LOCATION=./logs
exec > >(tee -i $LOG_LOCATION/installTools.log)
exec 2>&1

# Identifying Deployment
# usage: ./0-InstallTools.sh [deployment]
# deployment types are: ocp eks gcp aks
if [ -z $1 ]; then
  echo ""
  echo "====================================="
  echo "Usage:"
  echo "requires deployment type"
  echo ""
  echo "/> ./0-InstallTools.sh <deployment>"
  echo ""
  echo "deployment types are: ocp eks gcp aks"
  echo ""
  echo "====================================="   
  echo ""
  exit 1
fi

export DEPLOYMENT=$1
echo "============================"
echo "Deployment Type: $DEPLOYMENT"
echo "============================"
# save current directory for later in script
CURRENT_DIR=$(pwd)

# executable files will be copied here if required
mkdir -p $HOME/bin
export PATH=$HOME/bin:$PATH
echo "export PATH=$HOME/bin:$PATH" >> ~/.bashrc

# change to users home directory
cd ~

clear
echo "===================================================="
echo About to install required tools into:
pwd
echo ""
read -rsp $'Press ctrl-c to abort. Press any key to continue...\n====================================================' -n1 key

# Installation of hub
if ! [ -x "$(command -v hub)" ]; then
  echo "----------------------------------------------------"
  echo "Downloading git 'hub' utility ..."
  rm -rf hub-linux-amd64-2.10.0*
  wget https://github.com/github/hub/releases/download/v2.10.0/hub-linux-amd64-2.10.0.tgz
  tar -zxvf hub-linux-amd64-2.10.0.tgz
  echo "Installing git 'hub' utility ..."
  sudo ./hub-linux-amd64-2.10.0/install
  rm -rf hub-linux-amd64-2.10.0*
fi

# Installation of jq
if ! [ -x "$(command -v jq)" ]; then
  echo "----------------------------------------------------"
  echo "Installing git 'jq' utility ..."
  #sudo yum -y install jq
  wget -O jq https://github.com/stedolan/jq/releases/download/jq-1.6/jq-linux64
  chmod +x jq
  mv ./jq $HOME/bin/jq
fi

# Installation of kubectl
if ! [ -x "$(command -v kubectl)" ]; then
  echo "----------------------------------------------------"
  echo "Downloading 'kubectl' ..."
  curl -o kubectl https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/kubectl 
  echo "Installing 'kubectl' ..."
  chmod +x ./kubectl
  mv ./kubectl $HOME/bin/kubectl
fi

# Installation of oc (OpenShift CLI)
if [ $DEPLOYMENT == ocp ]; then
  if ! [ -x "$(command -v oc)" ]; then
    echo "----------------------------------------------------"
    echo "Downloading 'oc' ..."
    wget https://github.com/openshift/origin/releases/download/v3.11.0/openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz 
    echo "Installing 'oc' ..."
    tar xzf openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit.tar.gz
    cd openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit
    chmod +x oc
    mv oc $HOME/bin/oc
    rm -rf openshift-origin-client-tools-v3.11.0-0cbc58b-linux-64bit* 
  fi
fi

if [ $DEPLOYMENT == eks ]; then
  if ! [ -x "$(command -v aws-iam-authenicator)" ]; then
    echo "----------------------------------------------------"
    echo "Downloading 'aws-iam-authenticator' ..."
    https://docs.aws.amazon.com/eks/latest/userguide/install-aws-iam-authenticator.html
    rm aws-iam-authenticator
    curl -o aws-iam-authenticator https://amazon-eks.s3-us-west-2.amazonaws.com/1.11.5/2018-12-06/bin/linux/amd64/aws-iam-authenticator
    echo "Installing 'aws-iam-authenticator' ..."
    chmod +x ./aws-iam-authenticator
    mv ./aws-iam-authenticator $HOME/bin/aws-iam-authenticator 
  fi

  if ! [ -x "$(command -v terraform)" ]; then
    echo "----------------------------------------------------"
    echo "Downloading 'terraform' ..."
    rm -rf terraform_0.11.13_linux_amd64*
    rm -rf terraform
    wget https://releases.hashicorp.com/terraform/0.11.13/terraform_0.11.13_linux_amd64.zip
    echo "Installing 'terraform' ..."
    unzip terraform_0.11.13_linux_amd64.zip
    sudo cp terraform $HOME/bin/terraform
  fi
fi

# run a final validation
cd $CURRENT_DIR
./validatePrerequisites.sh
