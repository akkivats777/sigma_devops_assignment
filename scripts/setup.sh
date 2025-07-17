#!/bin/bash
set -e

echo "Setting up Minikube Deployment"
minikube start
# minikube start --cpus=4 --memory=8192

# Enable ingress
minikube addons enable ingress

# Install Local Path Provisioner for pvc volumes use locally not any cloud service (if not already)
kubectl apply -f https://raw.githubusercontent.com/rancher/local-path-provisioner/master/deploy/local-path-storage.yaml

# Set local-path as Default StorageClass
kubectl patch storageclass local-path -p '{"metadata": {"annotations":{"storageclass.kubernetes.io/is-default-class":"true"}}}'

# Enable Metrics Server for HPA
minikube addons enable metrics-server

# Verify
kubectl get --raw /apis/metrics.k8s.io/v1beta1/nodes || echo "Metrics Server not ready yet"

# Apply manifests (uncomment if needed)
# kubectl apply -f k8s_manifests/
# kubectl get ing -A