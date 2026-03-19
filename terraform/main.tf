resource "kubernetes_namespace" "apps" {
  metadata {
    # Shared namespace where all dynamically-created applications run.
    name = var.namespace

    labels = {
      managed-by = "terraform"
      project    = "candidate-task"
    }
  }
}