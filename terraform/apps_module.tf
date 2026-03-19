module "applications" {
  source = "./modules/k8s_application"
  # Reuse one module N times from locals.applications.
  for_each = local.applications

  name           = each.key
  namespace      = var.namespace
  image          = each.value.image
  container_port = each.value.container_port
  service_port   = each.value.service_port
  replicas       = each.value.replicas
  health_path    = each.value.health_path
  ready_path     = each.value.ready_path
}
