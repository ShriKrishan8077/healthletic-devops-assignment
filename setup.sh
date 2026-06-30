#!/bin/bash

set -e

echo "=========================================="
echo " Healthletic Server Setup Started"
echo "=========================================="

# Update packages
sudo apt update -y

############################################
# Docker
############################################

if ! command -v docker >/dev/null 2>&1; then
    echo "Installing Docker..."
    sudo apt install docker.io -y
    sudo systemctl enable docker
    sudo systemctl start docker
    sudo usermod -aG docker $USER
else
    echo "Docker already installed."
fi

############################################
# K3s
############################################

if ! command -v kubectl >/dev/null 2>&1; then
    echo "Installing K3s..."
    curl -sfL https://get.k3s.io | sh -
else
    echo "K3s already installed."
fi

############################################
# Configure kubeconfig
############################################

mkdir -p $HOME/.kube

sudo cp /etc/rancher/k3s/k3s.yaml $HOME/.kube/config

sudo chown $USER:$USER $HOME/.kube/config

export KUBECONFIG=$HOME/.kube/config

grep -qxF 'export KUBECONFIG=$HOME/.kube/config' ~/.bashrc || \
echo 'export KUBECONFIG=$HOME/.kube/config' >> ~/.bashrc

###########################################
# Helm
############################################

if ! command -v helm >/dev/null 2>&1; then
    echo "Installing Helm..."
    curl https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3 | bash
else
    echo "Helm already installed."
fi

#############################################
# Namespace
############################################

kubectl create namespace healthletic \
--dry-run=client -o yaml | kubectl apply -f -


echo ""
echo "=========================================="
echo " Server Setup Completed Successfully"
echo "=========================================="

echo ""

echo "Verify installation:"

docker --version

kubectl get nodes

helm version

echo ""

echo "Now run:"

echo "./deploy.sh dev 1.0.1 shrikrishansharma/healthletic-api"


export KUBECONFIG=$HOME/.kube/config
source ~/.bashrc