# GCP bastion host VM

Below are instructions for using the GCP CLI to provison an ubuntu virtual machine on GCP to use for the cluster, keptn, and application setup.

# Create bastion host

These instructions assume you have an GCP subscription and have the AZ CLI installed and configured locally.
 
See [GCP documentation](https://cloud.google.com/sdk/) for local CLI installation and configuration

You can also make the bastion host from the console and then continue with the steps to connect using ssh.  But you must use this image as to have the install scripts be compatible:
* Ubuntu 16.04 LTS

## 1. configure GCP CLI 

On your laptop, run these commands to configure the GCP CLI [GCP docs](https://cloud.google.com/sdk/)
```
# login to your account.  This will ask you to open a browser with a code and then login.
gcloud auth login

# Enable Google Compute APIs
gcloud services enable compute.googleapis.com

# Set GCP Account
gcloud config set account <email>

# Set your GCP Project id
gcloud config set project <project-id>

# To get information about your GCP Project
gcloud projects describe terraform-demo-236519
```

## 2. Provision bastion host using CLI

On your laptop, run these commands to provision the VM and a resource group
```

# set these values
export RESOURCE_PREFIX=<example your last name>
export PROJECT_ID="$(gcloud config get-value project -q)"
export VM_LOCATION=us-east1-b 
export VM_NAME="$RESOURCE_PREFIX"-dt-kube-demo-bastion
export VM_TYPE=f1-micro
export VM_NAME_SSH="$VM_NAME"-ssh
export VM_NAME_FWD="$VM_NAME"-fwd
export YOUR_IP=<Your IP>
export IMAGE_FAMILY=<Image Family>

# Create the Bastion Host
gcloud compute --project=$PROJECT_ID instances create $VM_NAME --zone=$VM_LOCATION --machine-type=$VM_TYPE --subnet=default --no-address --maintenance-policy=MIGRATE --no-service-account --no-scopes --tags=$VM_NAME --image-family=$IMAGE_FAMILY --image-project debian-cloud --boot-disk-size=10GB --boot-disk-type=pd-standard --boot-disk-device-name=$VM_NAME

# Create Firewall rule to allow ssh from your IP only

gcloud compute --project=$PROJECT_ID firewall-rules create $VM_NAME_SSH --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=tcp:22 --source-ranges=$YOUR_IP/32 --target-tags=$VM_NAME

# Create Firewall rule to allow traffic from the bastion to all other instances

gcloud compute --project=$PROJECT_ID firewall-rules create $VM_NAME_FWD --direction=INGRESS --priority=1000 --network=default --action=ALLOW --rules=all --source-tags=$VM_NAME
```

## 3. SSH bastion host

Goto the GCP console and Connect Menu to find the command to SSH to the Bastion Host.
```

## 4. Clone the Orders setup repo

Within the VM, run these commands to clone the setup repo.
```
git clone https://github.com/dt-kube-demo/setup-infra.git
cd setup-infra
```
Finally, proceed to the [Provision Cluster and onboard the Orders application](README.md#bastion-host-setup) step.

# Delete bastion host

## Option 1 - delete using GCP cli

From your laptop, run these commands to delete the VM. 

gcloud compute firewall-rules delete VM_NAME_SSH
gcloud compute firewall-rules delete VM_NAME_FWD 
gcloud compute instances delete $VM_NAME
```

## Option 2 - delete from the GCP console

On the GCP console, You can directly delete the bastion host and firewall rules.

# az command reference

```
# list of locations
gcloud compute regions list

# list vm VMs
gcloud compute instances list

# list vm sizes
gcloud compute machine-types list

# image types
gcloud compute images list

# firewall-rule list
gcloud compute firewall-rules list

```
gcloud compute --project=$PROJECT_ID instances create bastion --zone=$VM_LOCATION --machine-type=$VM_TYPE --subnet=default --no-address --maintenance-policy=MIGRATE --no-service-account --no-scopes --tags=$VM_NAME --image-family=$IMAGE_FAMILY --image-project debian-cloud --boot-disk-size=10GB --boot-disk-type=pd-standard --boot-disk-device-name=$VM_NAME