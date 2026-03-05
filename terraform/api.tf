# redis.tf — Redis deployment and service

resource "kubernetes_deployment" "api" {
  metadata {
    name      = "api"
    namespace = var.namespace

    labels = {
      app        = "api"
      environment = var.environment
      managed-by = "terraform"
    }
  }

  spec {
    replicas = var.api_replicas

    selector {
      match_labels = {
        app = "api"
      }
    }

    template {
      metadata {
        labels = {
          app = "api"
          environment = var.environment
        }
      }

      spec {
          image_pull_secrets {
              name = "google-registry-key"
          }
          
        container {
          name  = "api"
          image = var.api_image
          
          env {
            name  = "DATABASE_URL"
            value = "postgres://${var.POSTGRES_USER}:${var.POSTGRES_PASSWORD}@db-service:5432/${var.POSTGRES_DB}?sslmode=disable"
          }

          port {
            container_port = 3000
          }

          resources {
            requests = {
              cpu    = "10m"
              memory = "128Mi"
            }
            limits = {
              cpu    = "20m"
              memory = "256Mi"
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_service" "api" {
  metadata {
    name      = "api-service"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "api"
    }
    
    type = "LoadBalancer"

    port {
      port        = 80
      target_port = 3000
    }
  }
}
