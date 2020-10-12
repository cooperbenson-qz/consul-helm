#!/bin/bash

set -e

echo "running terraform apply"
terraform apply -auto-approve

kubectl get nodes

cd ../../acceptance/tests/
echo "running tests"
go test ./... -p 1 -timeout 20m -failfast \
  -enable-openshift \
  -debug-directory="/tmp/debug" \
  -consul-k8s-image=hashicorpdev/consul-k8s:latest