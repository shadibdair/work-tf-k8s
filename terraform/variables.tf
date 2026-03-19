variable "minikube_profile" {
  description = "Minikube profile name"
  type        = string
  default     = "task-k8s"
}

variable "namespace" {
  description = "Namespace for deployed applications"
  type        = string
  default     = "candidate-apps"
}

variable "enable_monitoring" {
  description = "Install kube-prometheus-stack and scrape app metrics via ServiceMonitor"
  type        = bool
  default     = false
}

variable "monitoring_namespace" {
  description = "Namespace where kube-prometheus-stack is installed"
  type        = string
  default     = "monitoring"
}