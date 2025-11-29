terraform {
  required_version = ">= 1.0"

  required_providers {
    cloudflare = {
      source  = "cloudflare/cloudflare"
      version = "~> 4.0"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "~> 2.25"
    }
    helm = {
      source  = "hashicorp/helm"
      version = "~> 2.11"
    }
  }
}

# Cloudflare Provider
provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

# Kubernetes Provider (configured via kubeconfig)
provider "kubernetes" {
  config_path = var.kubeconfig_path
}

# Helm Provider (uses Kubernetes provider)
provider "helm" {
  kubernetes {
    config_path = var.kubeconfig_path
  }
}
