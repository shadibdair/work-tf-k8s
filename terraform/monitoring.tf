resource "kubernetes_namespace" "monitoring" {
  count = var.enable_monitoring ? 1 : 0

  metadata {
    name = var.monitoring_namespace

    labels = {
      managed-by = "terraform"
      project    = "candidate-task"
    }
  }
}

locals {
  # Only scrape apps that expose a Prometheus /metrics endpoint.
  monitored_apps = [
    for name, app in local.applications : name
    if try(app.metrics_enabled, false)
  ]

  # Regex for relabeling in Prometheus extra scrape config.
  monitored_apps_regex = join("|", local.monitored_apps)
}

resource "helm_release" "kube_prometheus_stack" {
  count = var.enable_monitoring ? 1 : 0

  name       = "kube-prometheus-stack"
  namespace  = kubernetes_namespace.monitoring[0].metadata[0].name
  repository = "https://prometheus-community.github.io/helm-charts"
  chart      = "kube-prometheus-stack"
  version    = "82.10.5"

  # We configure Prometheus scraping via PrometheusSpec.additionalScrapeConfigs.
  # That avoids creating ServiceMonitor CRDs from Terraform.
  wait    = true
  timeout = 900

  values = [
    file("${path.module}/../helm/monitoring/values.yaml"),
    <<-EOT
prometheus:
  prometheusSpec:
    # Keep this separate from the Helm chart values file so Terraform can
    # dynamically match all apps defined in local.applications.
    additionalScrapeConfigs: |
      - job_name: candidate-apps
        scrape_interval: 15s
        kubernetes_sd_configs:
          - role: endpoints
        relabel_configs:
          - source_labels: [__meta_kubernetes_service_label_app]
            action: keep
            regex: ${local.monitored_apps_regex}
          - source_labels: [__meta_kubernetes_endpoint_port_name]
            action: keep
            regex: http
          # Expose the app name as a target label for easier dashboards.
          - source_labels: [__meta_kubernetes_service_label_app]
            target_label: app
            action: replace
          - target_label: __metrics_path__
            replacement: /metrics
EOT
  ]
}

