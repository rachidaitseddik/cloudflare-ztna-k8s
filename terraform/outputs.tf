output "tunnel_id" {
  description = "Cloudflare Tunnel ID (for reference/debugging)"
  value       = cloudflare_tunnel.k8s.id
}

output "tunnel_name" {
  description = "Cloudflare Tunnel name"
  value       = cloudflare_tunnel.k8s.name
}

output "namespace" {
  description = "Kubernetes namespace where cloudflared is deployed"
  value       = kubernetes_namespace.cloudflare_tunnel.metadata[0].name
}

output "cloudflared_pods" {
  description = "Verify cloudflared pods with: kubectl get pods -n {namespace}"
  value       = "kubectl get pods -n ${kubernetes_namespace.cloudflare_tunnel.metadata[0].name} -l app.kubernetes.io/name=cloudflared"
}

output "verify_tunnel_active" {
  description = "Check tunnel status in Cloudflare dashboard"
  value       = "https://one.dash.cloudflare.com/networks/tunnels/detail/${cloudflare_tunnel.k8s.id}"
}

output "dns_test_command" {
  description = "Test private DNS resolution from K8s cluster"
  value       = "kubectl run -it --rm debug --image=busybox --restart=Never -- nslookup kube-dns.kube-system.svc.cluster.local ${var.coredns_ip}"
}
