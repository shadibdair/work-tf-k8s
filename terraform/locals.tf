locals {
  # Providers read kubeconfig from the host machine.
  kubeconfig_path = pathexpand("~/.kube/config")

  # Single source of truth for all apps.
  # Add a new entry here to get a Deployment + Service + Ingress path automatically.
  applications = {
    app1 = {
      image          = "shadibdair/pod-meta-app:latest"
      container_port = 8080
      service_port   = 8080
      replicas       = 2
      path           = "/app1"
      health_path    = "/healthz"
      ready_path     = "/readyz"
    }

    app2 = {
      image          = "shadibdair/pod-meta-app:latest"
      container_port = 8080
      service_port   = 8080
      replicas       = 2
      path           = "/app2"
      health_path    = "/healthz"
      ready_path     = "/readyz"
    }

    podinfo = {
      image          = "stefanprodan/podinfo:6.7.1"
      container_port = 9898
      service_port   = 9898
      replicas       = 1
      path           = "/podinfo"
      health_path    = "/healthz"
      ready_path     = "/readyz"
    }
  }
}