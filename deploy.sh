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

helm lint ./helm/flask-api

helm upgrade --install healthletic ./helm/flask-api \
  --namespace healthletic \
  --create-namespace \
  --set image.repository=$IMAGE_REGISTRY \
  --set image.tag=$VERSION \
  --wait

kubectl rollout status deployment/healthletic -n healthletic

echo "Deployment Successful" | tee -a $LOG_FILE