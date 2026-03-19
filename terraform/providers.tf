provider "kubernetes" {
  # Target the Minikube context selected by minikube_profile.
  config_path    = local.kubeconfig_path
  config_context = var.minikube_profile
}

provider "helm" {
  # Kept aligned with the same kube context for optional Helm resources.
  kubernetes {
    config_path    = local.kubeconfig_path
    config_context = var.minikube_profile
  }
}