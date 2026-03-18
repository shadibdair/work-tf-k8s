resource "kubernetes_namespace" "apps" {
  metadata {
    name = var.namespace

    labels = {
      managed-by = "terraform"
      project    = "candidate-task"
    }
  }
}