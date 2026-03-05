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
    bucket = "chas-tf-state-the-hole"   # Your team's bucket from table above
    prefix = "terraform/state/erik"  # YOUR name! e.g. "terraform/state/daniel"
  }
}

provider "kubernetes" {
  config_path = "~/.kube/config"
}

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


