variable "name" {
  description = "Application name"
  type        = string
}

variable "namespace" {
  description = "Kubernetes namespace"
  type        = string
}

variable "image" {
  description = "Container image"
  type        = string
}

variable "container_port" {
  description = "Container port"
  type        = number
}

variable "service_port" {
  description = "Service port"
  type        = number
}

variable "replicas" {
  description = "Number of replicas"
  type        = number
  default     = 1
}

variable "health_path" {
  description = "HTTP path used by liveness probe"
  type        = string
  default     = "/healthz"
}

variable "ready_path" {
  description = "HTTP path used by readiness probe"
  type        = string
  default     = "/readyz"
}

variable "image_pull_policy" {
  description = "Kubernetes image pull policy for the application container"
  type        = string
  default     = "IfNotPresent"
}