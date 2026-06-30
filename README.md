# DEPLOYMENT_GUIDE.md

# Healthletic Flask API - Deployment Guide

## Overview

This project uses GitHub Actions to automate the complete CI/CD process.

Whenever code is pushed to the **main** branch or a Pull Request is created, GitHub Actions automatically:

* Builds the Docker image
* Scans the image using Trivy
* Pushes the image to Docker Hub
* Connects to the EC2 server using SSH
* Deploys the application to Kubernetes using Helm
* Runs smoke tests
* Rolls back automatically if deployment fails

---


# GitHub Actions Workflow

The workflow follows these stages:

## 1. Checkout Source Code

GitHub Actions downloads the latest source code from the repository.

---

## 2. Setup Python

Python is installed on the GitHub Actions runner and project dependencies are installed using:

```bash
pip install -r app/requirements.txt
```

---

## 3. Build Docker Image

A Docker image is created using the Dockerfile.

Example:

```text
shrikrishansharma/healthletic-api:v1.0.<run_number>
```

Each workflow run creates a unique image tag.

---

## 4. Security Scan

The Docker image is scanned using **Trivy**.

The scan checks for:

* Operating System vulnerabilities
* Python package vulnerabilities
* Known security issues

---

## 5. Push Image to Docker Hub

After a successful scan, the Docker image is pushed to Docker Hub.

---

## 6. Deploy to Kubernetes

GitHub Actions connects to the EC2 instance using SSH.

It then executes:

* Pull latest repository changes
* Upgrade Helm release
* Deploy the latest Docker image
* Wait until deployment is completed

---

## 7. Smoke Test

After deployment, the workflow performs smoke tests.

The following endpoints are verified:

```
/health
/db-health
```

The deployment is considered successful only if:

* API returns healthy status
* Database connection is successful

---

## 8. Automatic Rollback

If any smoke test fails:

* Helm automatically rolls back to the previous working release.
* The GitHub Actions workflow is marked as failed.

This prevents broken deployments from remaining active.

---






# Prerequisites

Before running the workflow, configure the following GitHub Secrets.

| Secret          | Description                           |
| --------------- | ------------------------------------- |
| DOCKER_USERNAME | Docker Hub username                   |
| DOCKER_PASSWORD | Docker Hub Access Token               |
| EC2_HOST        | Public IP address of the EC2 instance |
| EC2_USER        | SSH username (ubuntu)                 |
| EC2_SSH_KEY     | Private SSH key (.pem file content)   |

---




# Docker Registry

The project uses Docker Hub as the container registry.

Docker image format:

```
shrikrishansharma/healthletic-api:v1.0.<run_number>
```

---

# Manual Deployment

A PowerShell deployment script is included.

Run:

```powershell
.\deploy.ps1 dev 1.0.1 shrikrishansharma/healthletic-api
```

The script performs the following tasks:

* Validates input parameters
* Runs Helm lint
* Deploys the application using Helm
* Waits for rollout completion
* Runs smoke tests
* Rolls back automatically if deployment fails
* Writes deployment logs

---





# Troubleshooting

## Docker Push Failed

Possible reasons:

* Incorrect Docker Hub credentials
* Docker Hub login failed
* Network connectivity issue

Solution:

* Verify DOCKER_USERNAME
* Verify DOCKER_PASSWORD
* Test Docker login manually

---

## Helm Deployment Failed

Possible reasons:

* Kubernetes cluster is not running
* Incorrect Helm chart
* Invalid Kubernetes manifests

Solution:

```bash
kubectl get pods -n healthletic
```

```bash
helm lint ./helm/flask-api
```

```bash
kubectl describe pod <pod-name> -n healthletic
```

---

## Image Pull Failed

Possible reasons:

* Docker image does not exist
* Wrong image tag
* Registry authentication issue

Solution:

Verify that the Docker image exists in Docker Hub.

---

## Database Connection Failed

Possible reasons:

* MySQL pod is not running
* Incorrect database credentials
* Kubernetes Secret is missing

Solution:

```bash
kubectl get pods -n healthletic
```

```bash
kubectl logs <mysql-pod> -n healthletic
```

---

## Smoke Test Failed

Possible reasons:

* Application did not start successfully
* Database connection failed
* API endpoints are not responding

Solution:

Check:

```
/health
```

```
/db-health
```

Review pod logs:

```bash
kubectl logs <healthletic-pod> -n healthletic
```

---






# Rollback Procedure

Rollback is performed automatically if smoke tests fail.

To perform a manual rollback:

View release history:

```bash
helm history healthletic -n healthletic
```

Rollback to the previous release:

```bash
helm rollback healthletic -n healthletic
```

Verify deployment:

```bash
kubectl rollout status deployment/healthletic -n healthletic
```

Check running pods:

```bash
kubectl get pods -n healthletic
```

---



# Deployment Verification

Verify that the application is running:

```bash
kubectl get pods -n healthletic
```

Check services:

```bash
kubectl get svc -n healthletic
```

Start port forwarding:

```bash
kubectl port-forward --address 0.0.0.0 svc/healthletic 5000:5000 -n healthletic
```

Open in browser:

```
http://<EC2_PUBLIC_IP>:5000/
```

Health endpoint:

```
http://<EC2_PUBLIC_IP>:5000/health
```

Database health endpoint:

```
http://<EC2_PUBLIC_IP>:5000/db-health
```

---





# Conclusion

This project demonstrates a complete CI/CD pipeline using GitHub Actions, Docker, Trivy, Docker Hub, Kubernetes, Helm, and AWS EC2.

The pipeline automatically builds, scans, pushes, deploys, verifies, and rolls back the application, providing a reliable and repeatable deployment process.
