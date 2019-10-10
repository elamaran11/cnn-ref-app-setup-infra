#!/bin/bash

echo ""
echo "-------------------------------------------------------------------------------"
echo "kubectl get pods -n kube-system | grep beat"
echo "-------------------------------------------------------------------------------"
kubectl get pods -n kube-system | grep beat


