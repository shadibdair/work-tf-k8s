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
* **Unhealthy pods are recovered automatically** using liveness probes
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
* `podinfo` (bonus app using the same contract as app1/app2)

---

## 📂 Project Structure
```
app/
  ├── Dockerfile
  ├── requirements.txt
  └── src/
      └── app.py              # Flask app: /, /healthz, /readyz, /metrics (optional)

helm/
  └── monitoring/
      ├── values.yaml        # kube-prometheus-stack overrides (Grafana/Prometheus only)
      └── README.md

scripts/
  └── smoke-test.sh

terraform/
  ├── bootstrap/
  ├── environments/
  │   ├── local.tfvars        # enables monitoring locally
  │   └── ci.tfvars           # keeps monitoring disabled in CI
  ├── modules/
  │   └── k8s_application/
  │       ├── main.tf
  │       ├── variables.tf
  │       └── outputs.tf
  ├── main.tf
  ├── apps_module.tf
  ├── ingress.tf
  ├── providers.tf
  ├── outputs.tf
  ├── locals.tf
  └── monitoring.tf           # optional kube-prometheus-stack + Prometheus scraping

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
Option A (with Minikube tunnel):

```bash
minikube tunnel
```

Then access:

* [http://127.0.0.1/app1](http://127.0.0.1/app1)
* [http://127.0.0.1/app2](http://127.0.0.1/app2)
* [http://127.0.0.1/podinfo](http://127.0.0.1/podinfo)

Option B (without tunnel, using ingress port-forward):

```bash
kubectl -n ingress-nginx port-forward svc/ingress-nginx-controller 8080:80
```

Then access:

* [http://127.0.0.1:8080/app1](http://127.0.0.1:8080/app1)
* [http://127.0.0.1:8080/app2](http://127.0.0.1:8080/app2)
* [http://127.0.0.1:8080/podinfo](http://127.0.0.1:8080/podinfo)

All application routes return `pod_name` and `pod_ip` as required.

---


## 🧪 Smoke Test
Run:

```bash
./scripts/smoke-test.sh
```

If you are using Option B (Ingress port-forward on `:8080`), run:

```bash
SMOKE_BASE_URL=http://127.0.0.1:8080 ./scripts/smoke-test.sh
```

The script:

* Sends requests to all endpoints
* Fails immediately on error (`set -euo pipefail`)
* Validates JSON response contracts for each endpoint:
* The JSON response must include `pod_name` and `pod_ip`
* Supports scalable discovery:
  * `SMOKE_PATHS` (space-separated ingress paths like `/app1 /podinfo`)
  * `SMOKE_URLS` (space-separated full URLs)

Expected output:

```
Smoke tests passed.
```

Quick manual verification:

```bash
curl -s http://127.0.0.1:8080/app1 | jq .
curl -s http://127.0.0.1:8080/app2 | jq .
curl -s http://127.0.0.1:8080/podinfo | jq .
```

To test a custom set of endpoints:

```bash
SMOKE_BASE_URL=http://127.0.0.1:8080 SMOKE_PATHS="/app1 /podinfo" ./scripts/smoke-test.sh
```

Expected:

* Each tested endpoint returns JSON with `pod_name` and `pod_ip`

---


## 📈 Monitoring (kube-prometheus-stack)
This repository can optionally install `kube-prometheus-stack` into a separate `monitoring` namespace and scrape the apps that expose Prometheus metrics (via `GET /metrics`).

Notes:
* Monitoring is enabled via Terraform variable `enable_monitoring`.
* Prometheus scrapes the applications from `GET /metrics` (including `app1`, `app2`, and `podinfo`).
* The custom Flask apps (`app1` and `app2`) export Prometheus metrics at `/metrics` (via `prometheus-client`).
* `podinfo` is scraped from its `/metrics` endpoint (port `8080`).
* GitHub Actions CI keeps monitoring disabled (`terraform/environments/ci.tfvars` sets `enable_monitoring = false`).

Enable it locally:

```bash
# (1) Rebuild app image so it includes GET /metrics
docker buildx build --platform linux/amd64,linux/arm64 -t shadibdair/pod-meta-app:latest --push .

# (2) Apply Terraform (installs monitoring + app stack)
make tf-apply

# (3) Restart apps so they pick up the new image tag content
kubectl -n candidate-apps rollout restart deploy/app1 deploy/app2
```

Access Grafana:

```bash
kubectl -n monitoring port-forward svc/kube-prometheus-stack-grafana 3000:80
```

Then open: `http://127.0.0.1:3000`

Grafana dashboards (manual import from Grafana UI):
To visualize Kubernetes CPU/memory “per app”, import these dashboards and then filter by `Namespace` / `Pod`:
- `15757` → `Kubernetes / Views / Global`
- `15759` → `Kubernetes / Views / Nodes`
- `15760` → `Kubernetes / Views / Pods`
- `315` → `Kubernetes cluster monitoring via Prometheus`

In Grafana: `Dashboards` → `New` → `Import`, enter the dashboard ID, and pick your Prometheus datasource (from this stack).

## 🔄 CI Pipeline
GitHub Actions performs CI checks and then runs an end-to-end deploy+smoke test inside an **ephemeral Minikube** environment.

What CI does:

* Spins up a temporary **Minikube cluster inside the GitHub runner**
* Uses Terraform to provision Kubernetes resources:
  * Deployments
  * Services
  * Ingress
* Builds the Flask application image **inside that CI Minikube environment**
* Waits for deployments to become ready
* Runs smoke tests against the Ingress endpoint (via port-forward)

All of this happens **only inside CI**.

Once the workflow finishes, the runner is destroyed and the Minikube cluster no longer exists.

### What you see after pushing to GitHub

When you push to `main` (excluding README-only changes), GitHub Actions triggers `ci.yml` and you will see three jobs:

* **Terraform Checks** - runs `terraform init`, `terraform fmt -check`, and `terraform validate`
* **App Docker Build** - builds the app image from `./app/Dockerfile`
* **Deploy to Minikube + Smoke Test** - starts ephemeral Minikube, applies Terraform, waits for rollouts, and runs smoke tests

Expected flow in the Actions UI:

* `Terraform Checks` and `App Docker Build` complete first
* `Deploy to Minikube + Smoke Test` runs after `Terraform Checks` passes
* A successful run shows all jobs with green check marks

---

## 🧑‍💻 Local Development

Deployment to your local Minikube is performed manually:

```bash
minikube start -p task-k8s
minikube addons enable ingress

make tf-init
make tf-apply

minikube tunnel
```

Key clarification:

* CI validates the system end-to-end in an isolated environment
* Local Minikube is used for development and manual testing
* CI does not modify or update your local Minikube cluster

---


## 🧪 Run CI/CD locally (act)

You can run the GitHub Actions workflow locally using `act` (optional).

Requirements:

* Docker installed and running
* `act` installed

Run only the Terraform checks:

```bash
act -j terraform
```

Run the full deploy+smoke-test job (creates an ephemeral Minikube inside the local `act` environment):

```bash
act -j deploy-and-test
```

Notes:

* This mirrors CI behavior: it does not update your local Minikube cluster after the run ends.
* `act` compatibility depends on your host OS/architecture and local Docker setup.
* If `act` cannot start Minikube or fails due to local compatibility constraints, use:
  * GitHub Actions runs for CI verification
  * Manual steps in **Local Development** for local deployment/testing

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
      # Optional: enable Prometheus scraping for this app (only used when
      # Terraform variable enable_monitoring = true).
      metrics_enabled = true
      metrics_path    = "/metrics"
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
* **Liveness probes** restart unhealthy containers so pods recover automatically
* **Local Minikube** used for simplicity and fast setup
* CI performs end-to-end **ephemeral deployment + validation** inside a temporary GitHub runner Minikube environment

---



## 🤖 AI Usage

AI was used as a supporting tool for:

* Reviewing Terraform structure and module design
* Improving reusability patterns
* Refining README documentation
* Assisting with debugging ideas during development

All implementation, testing, validation, and final decisions were performed manually.

---


