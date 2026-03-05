 resource "kubernetes_ingress_v1" "app" {
metadata {
      name      = "the-hole-ingress"
      namespace = "the-hole"
      annotations = {
        "cert-manager.io/cluster-issuer" = "letsencrypt-prod"
      }
    }
    spec {
        ingress_class_name = "nginx"
      tls {
        hosts       = ["the-hole.chas.retro87.se"]
        secret_name = "the-hole-tls"
      }
      rule {
        host = "the-hole.chas.retro87.se"
        http {
          path {
            path      = "/"
            path_type = "Prefix"
            backend {
              service {
                name = "api-service"
                port {
                  number = 80
                }
              }
            }
          }
        }
      }
    }
  }
