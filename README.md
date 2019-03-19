# Overview

This repo has various scripts to make the Dynatrace Kubernetes demo application cloud hosted Kubernetes, Docker registry, Jenkins, Istio, and demo CI/CD pipelines.

Footnotes:
* Currently, these setup scripts support only AWS.  The plan is to support Azure, RedHat, and Cloud Foundry PaaS platforms.
* Terraform scripts are based from the full example in from https://github.com/cloudposse/terraform-aws-eks-cluster
* The Jenkins docker image is from: https://hub.docker.com/r/keptn/jenkins

# Dynatrace - Pre-requisites

Assumes you will use a trial SaaS dynatrace tenant from https://www.dynatrace.com/trial 

# AWS Setup - Pre-requisites

* AWS account used to provison PaaS resources.  Highly recommend, just signing up for free trial as to have full admin rights and to not cause any issues with your enterprise account.  https://aws.amazon.com/free/

