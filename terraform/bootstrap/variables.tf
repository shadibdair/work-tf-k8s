variable "minikube_profile" {
  description = "Minikube profile name"
  type        = string
  default     = "task-k8s"
}

variable "kubernetes_version" {
  description = "Minikube Kubernetes version"
  type        = string
  default     = "v1.34.0"
}

variable "driver" {
  description = "Minikube driver"
  type        = string
  default     = "docker"
}

variable "cpus" {
  description = "CPUs allocated to Minikube"
  type        = number
  default     = 4
}

variable "memory" {
  description = "Memory allocated to Minikube in MB"
  type        = number
  default     = 7168
}