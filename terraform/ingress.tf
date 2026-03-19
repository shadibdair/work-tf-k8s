resource "kubernetes_ingress_v1" "apps" {
  metadata {
    name      = "apps-ingress"
    namespace = var.namespace

    annotations = {
      # /appX is forwarded to backend "/" so apps can serve from root.
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      http {
        dynamic "path" {
          # Create one ingress path rule per app in locals.applications.
          for_each = local.applications

          content {
            path      = path.value.path
            path_type = "Prefix"

            backend {
              service {
                name = path.key

                port {
                  number = path.value.service_port
                }
              }
            }
          }
        }
      }
    }
  }
}