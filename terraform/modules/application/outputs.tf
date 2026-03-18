output "name" {
  value = var.name
}

output "service_name" {
  value = kubernetes_service.app.metadata[0].name
}