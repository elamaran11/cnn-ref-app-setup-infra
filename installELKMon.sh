#!/bin/bash

# Grab the configuration

git clone https://github.com/cnn-ref-app-k8s-beats.git

# Set the cluster-admin-binding

kubectl create clusterrolebinding cluster-admin-binding  \
  --clusterrole=cluster-admin --user=$(gcloud config get-value account)

# In a terminal configured to access your GKE On-Prem environment, check to see if kube-state-metrics is already running:

kubectl get pods --namespace=kube-system | grep kube-state

# If kube-state-metrics is already running, upgrade to a current version of GKE On-Prem that runs kube-state-metrics in a separate namespace before continuing.

# Install kube-state-metrics:

#git clone https://github.com/kubernetes/kube-state-metrics.git
git clone https://github.com/cnn-ref-app-kube-state-metrics.git

#kubectl create -f kube-state-metrics/kubernetes
kubectl apply -f cnn-ref-app-kube-state-metrics/examples/standard
kubectl get pods --namespace=kube-system | grep kube-state

# Create secrets

kubectl create secret generic kafka-host \
  --from-file=./cnn-ref-app-k8s-beats/kafka-hosts-ports --namespace=kube-system

# Deploy Filebeat and Metricbeat 

kubectl create -f cnn-ref-app-k8s-beats/filebeat-setup.yaml
kubectl create -f cnn-ref-app-k8s-beats/metricbeat-setup.yaml
# Verify
kubectl get pods -n kube-system | grep beat

# Deploy the Beat DaemonSets

kubectl create -f cnn-ref-app-k8s-beats/filebeat-kubernetes.yaml
kubectl create -f cnn-ref-app-k8s-beats/metricbeat-kubernetes.yaml

# Verify
kubectl get pods -n kube-system | grep beat
