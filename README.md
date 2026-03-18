# 🚀 Kubernetes + Terraform Project (Minikube)

## 📌 Overview

This project provisions and manages Kubernetes applications using
Terraform on a local Minikube cluster.

It demonstrates: - Infrastructure as Code (Terraform) - Kubernetes
deployments and services - Reusable Terraform modules - Ingress
routing - CI validation with GitHub Actions - Smoke testing

------------------------------------------------------------------------

## 🏗️ Architecture

-   Minikube cluster
-   NGINX Ingress Controller
-   Namespace: `candidate-apps`
-   Applications:
    -   app1
    -   app2
    -   podinfo

------------------------------------------------------------------------

## 📂 Project Structure

    terraform/
      ├── modules/
      ├── environments/
      ├── main.tf
      ├── applications.tf
      ├── ingress.tf

    scripts/
      └── smoke-test.sh

    .github/workflows/
      └── ci.yml

------------------------------------------------------------------------

## ⚙️ Setup

### 1. Start Minikube

    minikube start -p task-k8s
    minikube profile task-k8s

### 2. Enable Ingress

    minikube addons enable ingress

### 3. Terraform Init

    make tf-init

### 4. Apply Infrastructure

    make tf-apply

------------------------------------------------------------------------

## 🌐 Access Applications

Run:

    minikube tunnel

Then access:

-   http://127.0.0.1/app1
-   http://127.0.0.1/app2
-   http://127.0.0.1/podinfo

------------------------------------------------------------------------

## 🧪 Smoke Test

    ./scripts/smoke-test.sh

Expected: - All endpoints return valid responses - "Smoke tests passed"

------------------------------------------------------------------------

## 🔄 CI Pipeline

GitHub Actions performs:

-   terraform fmt
-   terraform validate
-   docker build

------------------------------------------------------------------------

## 🧠 Design Decisions

-   Used Terraform for full lifecycle management
-   Replaced duplicated modules with reusable structure
-   Used Ingress instead of NodePort for clean routing
-   Avoided apply in CI (local cluster dependency)

------------------------------------------------------------------------

