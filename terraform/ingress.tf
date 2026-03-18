resource "kubernetes_ingress_v1" "apps" {
  metadata {
    name      = "apps-ingress"
    namespace = var.namespace

    annotations = {
      "nginx.ingress.kubernetes.io/rewrite-target" = "/"
    }
  }

  spec {
    ingress_class_name = "nginx"

    rule {
      http {
        dynamic "path" {
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