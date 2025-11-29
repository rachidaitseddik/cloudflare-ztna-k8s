# ============================================================================
# Kubernetes Namespace for Cloudflare Tunnel
# ============================================================================

resource "kubernetes_namespace" "cloudflare_tunnel" {
  metadata {
    name = local.namespace
    labels = merge(
      local.common_labels,
      {
        "pod-security.kubernetes.io/enforce" = "baseline"
      }
    )
  }
}

# ============================================================================
# Kubernetes Secret: Tunnel Credentials
# Stores the base64-encoded tunnel credentials and certificate
# ============================================================================

resource "kubernetes_secret" "cloudflared_credentials" {
  metadata {
    name      = "cloudflared-credentials"
    namespace = kubernetes_namespace.cloudflare_tunnel.metadata[0].name
    labels    = local.common_labels
  }

  data = {
    "credentials.json" = base64decode(var.tunnel_secret_base64)
    "cert.pem"         = base64decode(var.tunnel_cert_base64)
  }

  type = "Opaque"
}

# ============================================================================
# Helm Chart: Cloudflared (using community-charts)
# This deploys the cloudflared daemon in private network mode
# ============================================================================

resource "helm_release" "cloudflared" {
  name             = "cloudflared"
  repository       = "https://community-charts.github.io/helm-charts"
  chart            = "cloudflared"
  version          = "~> 0.1"
  namespace        = kubernetes_namespace.cloudflare_tunnel.metadata[0].name
  create_namespace = false

  values = [yamlencode({
    # Image configuration
    image = {
      repository = "cloudflare/cloudflared"
      tag        = "2024.11.0"
      pullPolicy = "IfNotPresent"
    }

    # Deployment strategy: Run 2 replicas across multiple nodes
    replicaCount = 2

    replicas = {
      allNodes = false
      count    = 2
    }

    # Update strategy
    strategy = {
      type = "RollingUpdate"
      rollingUpdate = {
        maxSurge       = 1
        maxUnavailable = 0
      }
    }

    # Tunnel Configuration
    tunnelConfig = {
      name                   = cloudflare_tunnel.k8s.name
      accountId              = var.cloudflare_account_id
      tunnelId               = cloudflare_tunnel.k8s.id
      logLevel               = "info"
      transportLogLevel      = "warn"
      protocol               = "quic" # CRITICAL: Must be QUIC for UDP DNS
      retries                = 5
      connectTimeout         = "30s"
      gracePeriod            = "30s"
      metricsUpdateFrequency = "5s"
      noAutoUpdate           = false
      warpRouting = {
        enabled = true
      }
    }

    # Tunnel Credentials (from Kubernetes secret)
    tunnelSecrets = {
      existingSecret  = kubernetes_secret.cloudflared_credentials.metadata[0].name
      credentialsFile = "credentials.json"
      certFile        = "cert.pem"
    }

    # Service Account & RBAC
    serviceAccount = {
      create = true
      name   = "cloudflared"
      annotations = {
        "managed-by" = "terraform"
      }
    }

    # Resource Limits
    resources = {
      requests = {
        memory = "128Mi"
        cpu    = "100m"
      }
      limits = {
        memory = "512Mi"
        cpu    = "500m"
      }
    }

    # Probes (Health Checks)
    livenessProbe = {
      enabled             = true
      initialDelaySeconds = 30
      periodSeconds       = 10
      timeoutSeconds      = 5
      failureThreshold    = 3
    }

    readinessProbe = {
      enabled             = true
      initialDelaySeconds = 10
      periodSeconds       = 5
      timeoutSeconds      = 3
      failureThreshold    = 3
    }

    # Pod Disruption Budget (High Availability)
    podDisruptionBudget = {
      enabled      = true
      minAvailable = 1
    }

    # Security Context
    securityContext = {
      runAsNonRoot             = true
      runAsUser                = 65534
      readOnlyRootFilesystem   = false
      allowPrivilegeEscalation = false
      capabilities = {
        drop = ["ALL"]
      }
    }

    # Affinity (pod scheduling preferences)
    affinity = {
      podAntiAffinity = {
        preferredDuringSchedulingIgnoredDuringExecution = [
          {
            weight = 100
            podAffinityTerm = {
              labelSelector = {
                matchExpressions = [
                  {
                    key      = "app.kubernetes.io/name"
                    operator = "In"
                    values   = ["cloudflared"]
                  }
                ]
              }
              topologyKey = "kubernetes.io/hostname"
            }
          }
        ]
      }
    }

    # Service and Ingress (not needed for private network mode)
    service = {
      enabled = false
    }

    ingress = {
      enabled = false
    }
  })]

  wait    = true
  timeout = 600

  depends_on = [
    kubernetes_secret.cloudflared_credentials
  ]
}
