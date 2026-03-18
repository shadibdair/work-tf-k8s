resource "null_resource" "minikube_start" {
  triggers = {
    profile            = var.minikube_profile
    kubernetes_version = var.kubernetes_version
    driver             = var.driver
    cpus               = tostring(var.cpus)
    memory             = tostring(var.memory)
  }

  provisioner "local-exec" {
    command     = <<-EOT
      set -euo pipefail

      minikube start \
        --profile=${var.minikube_profile} \
        --kubernetes-version=${var.kubernetes_version} \
        --driver=${var.driver} \
        --cpus=${var.cpus} \
        --memory=${var.memory}

      minikube addons enable ingress --profile=${var.minikube_profile}
      kubectl config use-context ${var.minikube_profile}

      kubectl wait \
        --namespace ingress-nginx \
        --for=condition=Ready pods \
        --selector=app.kubernetes.io/component=controller \
        --timeout=180s
    EOT
    interpreter = ["/bin/bash", "-c"]
  }
}