# 🚀 Kubernetes + Terraform Project (Minikube)

## 📌 Overview

This project demonstrates **Infrastructure as Code (IaC)** and automation by provisioning and managing Kubernetes applications using **Terraform** on a local **Minikube** cluster.

The solution focuses on:

* Reusability and minimal code duplication
* Dynamic provisioning of multiple applications
* Clean and scalable networking
* Simple CI validation pipeline

---

## ✅ Requirements Mapping

This implementation fully satisfies the task requirements:

* **Terraform provisions a local Kubernetes environment**
* **Deploys N applications dynamically** using a reusable module and `for_each`
* Each application returns:
  * Pod name
  * Pod IP address
* **Single local endpoint** using Ingress
* **Dynamic routing** to multiple applications:
  * `/app1`
  * `/app2`
  * `/podinfo`
* **Traffic is routed only to healthy pods** using readiness probes
* Each application has a **distinct and accessible route**

---

## 🏗️ Architecture

```
Client (localhost)
        ↓
NGINX Ingress
        ↓
Services (ClusterIP)
        ↓
Pods (Deployments)
```

### Components:

* **Minikube** – local Kubernetes cluster
* **NGINX Ingress Controller** – routing layer
* **Terraform** – infrastructure provisioning
* **Reusable Application Module** – deploys apps dynamically
* **Namespace:** `candidate-apps`

### Applications:

* `app1` (custom Flask app)
* `app2` (custom Flask app)
* `podinfo` (external demo app)

---

## 📂 Project Structure

```
terraform/
  ├── bootstrap/              # Minikube bootstrap (local execution)
  ├── modules/
  │     └── application/      # Reusable app module (Deployment + Service)
  ├── environments/
  │     └── local.tfvars
  ├── main.tf
  ├── applications.tf         # Dynamic apps definition
  ├── ingress.tf              # Dynamic routing

scripts/
  └── smoke-test.sh

.github/workflows/
  └── ci.yml
```


## ⚙️ Prerequisites

Make sure you have installed:

* Terraform
* Docker
* Minikube
* kubectl
* Helm

---

## ⚙️ Setup

### 1. Start Minikube
```bash
minikube start -p task-k8s
minikube profile task-k8s
```

### 2. Enable Ingress
```bash
minikube addons enable ingress
```

### 3. Initialize Terraform

```bash
make tf-init
```

### 4. Apply Infrastructure

```bash
make tf-apply
```

---


## 🌐 Access Applications
Run:

```bash
minikube tunnel
```

Then access:

* [http://127.0.0.1/app1](http://127.0.0.1/app1)
* [http://127.0.0.1/app2](http://127.0.0.1/app2)
* [http://127.0.0.1/podinfo](http://127.0.0.1/podinfo)

---


## 🧪 Smoke Test
Run:

```bash
./scripts/smoke-test.sh
```

The script:

* Sends requests to all endpoints
* Fails immediately on error (`set -euo pipefail`)
* Ensures all applications respond correctly

Expected output:

```
Smoke tests passed.
```

---


## 🔄 CI Pipeline
GitHub Actions performs:

* `terraform fmt -check`
* `terraform validate`
* `terraform init`
* `docker build`

> Deployment is intentionally not executed in CI because the target environment is a local Minikube cluster.

---


## 🔁 How It Works

* Applications are defined in a **map (`locals.applications`)**
* Terraform uses **`for_each`** to dynamically create:
  * Deployments
  * Services
  * Ingress routes
* Adding a new application requires **only a new entry in the map**

---

## ➕ Adding a New Application

To add a new application, update:

```hcl
locals {
  applications = {
    myapp = {
      image          = "example/myapp:latest"
      container_port = 8080
      service_port   = 8080
      replicas       = 1
      path           = "/myapp"
      health_path    = "/healthz"
      ready_path     = "/readyz"
    }
  }
}
```

Then run:

```bash
terraform apply
```

No additional Terraform resources are required.

---

## 🧠 Design Decisions

* **Terraform** was chosen to demonstrate IaC, modularity, and reusability
* **Reusable module + for_each** minimizes duplication and supports scaling to N apps
* **Ingress (NGINX)** provides a single endpoint with clean routing
* **Path-based routing** is simpler and suitable for local environments
* **Readiness probes** ensure traffic is routed only to healthy pods
* **Local Minikube** used for simplicity and fast setup
* CI focuses on **validation**, not deployment, due to local environment constraints

---



## 🤖 AI Usage

AI was used as a supporting tool for:

* Reviewing Terraform structure and module design
* Improving reusability patterns
* Refining README documentation
* Assisting with debugging ideas during development

All implementation, testing, validation, and final decisions were performed manually.

---


