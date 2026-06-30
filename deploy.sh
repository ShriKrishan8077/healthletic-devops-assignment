#!/bin/bash

set -e

ENVIRONMENT=$1
VERSION=$2
IMAGE_REGISTRY=$3

LOG_FILE=deploy.log

echo "Deployment Started..." | tee -a $LOG_FILE

if [ -z "$ENVIRONMENT" ] || [ -z "$VERSION" ] || [ -z "$IMAGE_REGISTRY" ]; then
    echo "Usage: ./deploy.sh <environment> <version> <image_registry>"
    exit 1
fi

export KUBECONFIG=$HOME/.kube/config

helm lint ./helm/flask-api

helm upgrade --install healthletic ./helm/flask-api \
  --namespace healthletic \
  --create-namespace \
  --set image.repository=$IMAGE_REGISTRY \
  --set image.tag=$VERSION \
  --wait

kubectl rollout status deployment/healthletic -n healthletic

# Smoke Test
kubectl port-forward svc/healthletic 5000:5000 -n healthletic >/dev/null 2>&1 &
PF_PID=$!

sleep 5

HEALTH=$(curl -s http://localhost:5000/health | grep healthy)
DB=$(curl -s http://localhost:5000/db-health | grep connected)

if [ -n "$HEALTH" ] && [ -n "$DB" ]; then
    echo "Smoke Test Passed" | tee -a $LOG_FILE
    kill $PF_PID
else
    echo "Smoke Test Failed. Rolling back..." | tee -a $LOG_FILE
    kill $PF_PID
    helm rollback healthletic -n healthletic
    exit 1
fi

echo "Deployment Successful" | tee -a $LOG_FILE