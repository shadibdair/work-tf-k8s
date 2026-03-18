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