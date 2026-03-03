# redis.tf — Redis deployment and service

resource "kubernetes_deployment" "api" {
  metadata {
    name      = "api"
    namespace = var.namespace

    labels = {
      app        = "api"
      managed-by = "terraform"
    }
  }

  spec {
    replicas = 2

    selector {
      match_labels = {
        app = "api"
      }
    }

    template {
      metadata {
        labels = {
          app: "api"
        }
      }

      spec {
        container {
          name  = "api"
          image = "danielwchas/dice-app:v7"

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

    port {
      port        = 3000
      target_port = 3000
    }
  }
}
