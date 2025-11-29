locals {
  tunnel_name = "k8s-${var.cloudflare_account_id}"
  namespace   = var.kubernetes_namespace

  # Common labels for all resources
  common_labels = {
    managed-by  = "terraform"
    component   = "cloudflare-tunnel"
    environment = "production"
  }
}
