
resource "kubernetes_deployment" "db" {
  metadata {
    name      = "db"
    namespace = var.namespace

    labels = {
      app        = "db"
      managed-by = "terraform"
    }
  }

  spec {
    replicas = 1

    selector {
      match_labels = {
        app = "db"
      }
    }

    template {
      metadata {
        labels = {
          app = "db"
        }
      }

      spec {
        container {
          name  = "postgres"
          image = "postgres:15"
#	  env 
#		- name: POSTGRES_USER
#		  value: var.POSTGRES_USER
#		- name: POSTGRES_DB
#		  value: var.POSTGRES_DB
#		- name: POSTGRES_PASSWORD
#	 	  value: var.POSTGRES_PASSWORD
	env {
	name = "POSTGRES_USER"
	value = var.POSTGRES_USER
}	
	env {
	name = "POSTGRES_PASSWORD"
	value = var.POSTGRES_PASSWORD
}
	env {
	name = "POSTGRES_DB"
	value = var.POSTGRES_DB
}

          port {
            container_port = 5432
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

resource "kubernetes_service" "db" {
  metadata {
    name      = "db-service"
    namespace = var.namespace
  }

  spec {
    selector = {
      app = "db"
    }

    port {
      port        = 5432
      target_port = 5432
    }
  }
}
