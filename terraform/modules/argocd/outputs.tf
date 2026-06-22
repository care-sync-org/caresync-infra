data "kubernetes_secret" "argocd_admin_password" {
  metadata {
    name      = "argocd-initial-admin-secret"
    namespace = "argocd"
  }

  depends_on = [helm_release.argocd]
}

output "argocd_admin_password" {
  value       = data.kubernetes_secret.argocd_admin_password.data["password"]
  sensitive   = true
  description = "Initial ArgoCD admin password. Retrieve with: terraform output -raw argocd_admin_password"
}
