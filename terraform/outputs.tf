output "minikube_profile" {
  description = "Minikube profile name"
  value       = var.minikube_profile
}

output "namespace" {
  description = "Applications namespace"
  value       = kubernetes_namespace.apps.metadata[0].name
}

output "kube_context" {
  description = "Kubectl context used by Terraform"
  value       = var.minikube_profile
}

output "application_routes" {
  description = "Application routes exposed through ingress"
  value = {
    for app_name, app in local.applications :
    app_name => "http://127.0.0.1${app.path}"
  }
}