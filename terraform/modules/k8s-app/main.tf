# modules/k8s-app/main.tf — Reusable app deployment module

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

variable "port" {
  description = "Container port"
  type        = number
}

variable "target_port" {
  description = "target port"
  type        = number
}
variable "replicas" {
  description = "Number of replicas"
  type        = number
  default     = 1
}

variable "cpu_request" {
  type    = string
  default = "10m"
}

variable "memory_request" {
  type    = string
  default = "128Mi"
}

variable "cpu_limit" {
  type    = string
  default = "500m"
}

variable "memory_limit" {
  type    = string
  default = "512Mi"
}

variable "env_vars" {
  description = "Environment variables for the container"
  type        = map(string)
  default     = {}
}

variable "labels" {
  description = "Additional labels"
  type        = map(string)
  default     = {}
}

# --- Resources ---

resource "kubernetes_deployment" "app" {
  metadata {
    name      = var.name
    namespace = var.namespace
    labels = merge({
      app        = var.name
      managed-by = "terraform"
    }, var.labels)
  }

  spec {
    replicas = var.replicas
    selector {
      match_labels = { app = var.name }
    }
    template {
      metadata {
        labels = merge({ app = var.name }, var.labels)
      }
      spec {
        container {
          name  = var.name
          image = var.image
          port {
            container_port = var.port
          }
          resources {
            requests = {
              cpu    = var.cpu_request
              memory = var.memory_request
            }
            limits = {
              cpu    = var.cpu_limit
              memory = var.memory_limit
            }
          }
          dynamic "env" {
            for_each = var.env_vars
            content {
              name  = env.key
              value = env.value
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "app" {
  metadata {
    name      = "${var.name}-service"
    namespace = var.namespace
  }
  spec {
    selector = { app = var.name }
    port {
      port        = var.port
      target_port = var.target_port
    }
  }
}

# --- Outputs ---

output "deployment_name" {
  value = kubernetes_deployment.app.metadata[0].name
}

output "service_name" {
  value = kubernetes_service.app.metadata[0].name
}

output "service_dns" {
  value = "${kubernetes_service.app.metadata[0].name}.${var.namespace}.svc.cluster.local"
}
