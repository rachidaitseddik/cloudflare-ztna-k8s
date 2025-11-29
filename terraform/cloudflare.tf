# ============================================================================
# Cloudflare Tunnel Configuration
# This resource ensures the tunnel exists in Cloudflare
# ============================================================================

resource "cloudflare_tunnel" "k8s" {
  account_id = var.cloudflare_account_id
  name       = local.tunnel_name
  secret     = base64decode(var.tunnel_secret_base64)
}

# ============================================================================
# Cloudflare Tunnel Route (Private Network CIDR)
# This tells Cloudflare to route your Service CIDR through the tunnel
# ============================================================================

resource "cloudflare_tunnel_route" "k8s_private_network" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_tunnel.k8s.id
  network    = var.service_cidr
  comment    = "Route Kubernetes Service CIDR through tunnel for private network access"
}

# ============================================================================
# Cloudflare Tunnel Credentials Configuration
# This registers the tunnel in the Cloudflare API (required for WARP routing)
# ============================================================================

resource "cloudflare_tunnel_config" "k8s" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_tunnel.k8s.id

  config {
    warp_routing {
      enabled = true
    }
  }
}
