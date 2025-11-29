variable "cloudflare_api_token" {
  description = "Cloudflare API token with Tunnel and DNS permissions"
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" {
  description = "Cloudflare Account ID (found in Workers dashboard)"
  type        = string
}

variable "kubeconfig_path" {
  description = "Path to kubeconfig file"
  type        = string
  default     = "~/.kube/config"
}

variable "kubernetes_namespace" {
  description = "Kubernetes namespace for cloudflared"
  type        = string
  default     = "cloudflare-tunnel"
}

variable "tunnel_id" {
  description = "Cloudflare Tunnel ID"
  type        = string
}

variable "tunnel_secret_base64" {
  description = "Base64-encoded tunnel credentials JSON"
  type        = string
  sensitive   = true
}

variable "tunnel_cert_base64" {
  description = "Base64-encoded tunnel certificate (cert.pem)"
  type        = string
  sensitive   = true
}

variable "service_cidr" {
  description = "Kubernetes Service CIDR (e.g., 10.245.0.0/16)"
  type        = string
}

variable "coredns_ip" {
  description = "ClusterIP of CoreDNS/kube-dns service (e.g., 10.245.0.10)"
  type        = string
}

variable "private_domain_suffix" {
  description = "Private domain suffix (e.g., 'cluster.local', 'internal.corp')"
  type        = string
  default     = "cluster.local"
}
