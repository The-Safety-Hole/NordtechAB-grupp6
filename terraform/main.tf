# main.tf — Terraform config for your team namespace

terraform {
  required_providers {
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.35"
    }
  }

  # Store state in Google Cloud Storage
  backend "gcs" {
    bucket = "chas-tf-state-the-hole"  # Replace with your team's bucket
    prefix = "terraform/state/jonas"
  }
}

# Use your existing kubeconfig — the same one from Week 6
provider "kubernetes" {
  config_path = "~/.kube/config"
  # Or if you use KUBECONFIG env var, Terraform picks it up automatically
}

# --- API ---
module "api" {
  source    = "./modules/k8s-app"
  name      = "api"
  namespace = var.namespace
  image     = var.api_image
  port      = 3000
  replicas  = var.api_replicas

}

# --- DB ---
module "db" {
  source	= "./modules/k8s-app"
  name		= "db"
  namespace = var.namespace
  image		= var.db_image
  port		= 5432
  replicas  = var.db_replicas


  env_vars = {
  POSTGRES_USER = var.POSTGRES_USER
  POSTGRES_DB   = var.POSTGRES_DB
  POSTGRES_PASSWORD = var.POSTGRES_PASSWORD
}
 }

module "team-monitor" {
  source     = "./modules/k8s-app"
  name		 = "team-monitor"
  namespace  = var.namespace
  im
# Create a ConfigMap in your team namespace
resource "kubernetes_config_map" "app_config" {
  metadata {
    name      = "terraform-demo"
    namespace = "the-hole"  # Replace: girly-pops, m4k-gang, etc.

    labels = {
      "managed-by" = "terraform"
      "team"       = "the-hole"
    }
  }

  data = {
    APP_ENV     = "production"
    APP_VERSION = "1.0.0"
    MANAGED_BY  = "terraform"
  }
}
