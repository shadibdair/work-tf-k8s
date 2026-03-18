provider "kubernetes" {
  config_path    = local.kubeconfig_path
  config_context = var.minikube_profile
}

provider "helm" {
  kubernetes {
    config_path    = local.kubeconfig_path
    config_context = var.minikube_profile
  }
}