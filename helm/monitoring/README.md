# Monitoring Helm Values (kube-prometheus-stack)

This folder contains Helm values overrides used by Terraform when installing `kube-prometheus-stack`.

It is intentionally scoped to:
- Enable Grafana
- Disable Alertmanager UI
- Enable the metrics components needed for CPU/memory dashboards
- Enable the Grafana dashboard sidecar to auto-import dashboards from ConfigMaps

