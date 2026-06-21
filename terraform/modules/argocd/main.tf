# =============================================================================
# ArgoCD Module
# Installs ArgoCD via Helm and creates the initial CareSync Application
# resource to bootstrap the full GitOps loop automatically.
# =============================================================================

variable "gitops_repo_url"   { type = string }
variable "gitops_branch"     { type = string  default = "dev" }
variable "argocd_version"    { type = string  default = "7.3.11" }

# -----------------------------------------------------------------------------
# Step 1: Create the argocd namespace explicitly so Terraform tracks it
# -----------------------------------------------------------------------------
resource "kubernetes_namespace" "argocd" {
  metadata {
    name = "argocd"
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
}

# -----------------------------------------------------------------------------
# Step 2: Install ArgoCD via the official Helm chart
# -----------------------------------------------------------------------------
resource "helm_release" "argocd" {
  name       = "argocd"
  repository = "https://argoproj.github.io/argo-helm"
  chart      = "argo-cd"
  namespace  = kubernetes_namespace.argocd.metadata[0].name
  version    = var.argocd_version

  # Disable the default Redis HA for dev — uses less resources
  set {
    name  = "redis-ha.enabled"
    value = "false"
  }

  # Keep ArgoCD server in non-TLS mode (TLS is terminated at ALB)
  set {
    name  = "server.extraArgs[0]"
    value = "--insecure"
  }

  # Wait until all ArgoCD pods are running before Terraform continues
  wait    = true
  timeout = 600  # 10 minutes

  depends_on = [kubernetes_namespace.argocd]
}

# -----------------------------------------------------------------------------
# Step 3: Create the CareSync GitOps Application in ArgoCD
# This is the "root app" that tells ArgoCD to watch caresync-gitops.
# Once applied, ArgoCD automatically deploys ALL 7 microservices.
# -----------------------------------------------------------------------------
resource "kubernetes_manifest" "caresync_app" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name       = "caresync-dev"
      namespace  = "argocd"
      finalizers = ["resources-finalizer.argocd.argoproj.io"]
    }
    spec = {
      project = "default"
      source = {
        repoURL        = var.gitops_repo_url
        targetRevision = var.gitops_branch
        path           = "helm"
        helm = {
          valueFiles = ["values.yaml", "values-dev.yaml"]
        }
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "caresync-dev"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true",
          "ServerSideApply=true"
        ]
        retry = {
          limit = 3
          backoff = {
            duration    = "5s"
            maxDuration = "3m"
            factor      = 2
          }
        }
      }
    }
  }

  # CRITICAL: ArgoCD CRDs must exist before we can create an Application resource
  depends_on = [helm_release.argocd]
}

# -----------------------------------------------------------------------------
# Output the initial ArgoCD admin password so you don't have to run kubectl
# -----------------------------------------------------------------------------
data "kubernetes_secret" "argocd_admin_password" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }

  depends_on = [helm_release.argocd]
}

output "argocd_admin_password" {
  value     = data.kubernetes_secret.argocd_admin_password.data["password"]
  sensitive = true
  description = "Initial ArgoCD admin password. Retrieve with: terraform output -raw argocd_admin_password"
}
