
# Monitor Deployment

resource "kubernetes_deployment" "monitor" {

  metadata {
    name      = "monitor"
    namespace = var.namespace

    labels = {
      app         = "monitor"
      environment = var.environment
      managed-by  = "terraform"
    }
  }

  spec {

    replicas = var.monitor_replicas

    selector {
      match_labels = {
        app = "monitor"
      }
    }

    template {

      metadata {
        labels = {
          app         = "monitor"
          environment = var.environment
        }
      }

      spec {

        container {

          name  = "monitor"
          image = var.monitor_image

          port {
            container_port = 3000
          }

          resources {
            requests = {
              cpu    = "100m"
              memory = "128Mi"
            }

            limits = {
              cpu    = "200m"
              memory = "256Mi"
            }
          }

        }

      }

    }

  }

}


# Monitor Service


resource "kubernetes_service" "monitor_service" {

  metadata {
    name      = "monitor-service"
    namespace = var.namespace
  }

  spec {

    selector = {
      app = "monitor"
    }

    port {
      port        = 3000
      target_port = 3000
    }

  }

}
