# =============================================================================
# ALB Controller Module
# Installs the AWS Load Balancer Controller into the EKS cluster via Helm.
# The IAM role is created by the iam-irsa module and passed in here.
# =============================================================================


# -----------------------------------------------------------------------------
# Create the kube-system namespace (already exists in EKS but Terraform needs
# to know about it to manage resources inside it consistently)
# -----------------------------------------------------------------------------
resource "kubernetes_service_account" "albc" {
  metadata {
    name      = "aws-load-balancer-controller"
    namespace = "kube-system"
    annotations = {
      "eks.amazonaws.com/role-arn" = var.albc_role_arn
    }
    labels = {
      "app.kubernetes.io/name"      = "aws-load-balancer-controller"
      "app.kubernetes.io/component" = "controller"
    }
  }
}

# -----------------------------------------------------------------------------
# Install the AWS Load Balancer Controller using the official Helm chart
# -----------------------------------------------------------------------------
resource "helm_release" "alb_controller" {
  name       = "aws-load-balancer-controller"
  repository = "https://aws.github.io/eks-charts"
  chart      = "aws-load-balancer-controller"
  namespace  = "kube-system"
  version    = "1.8.1"

  set {
    name  = "clusterName"
    value = var.cluster_name
  }

  set {
    name  = "serviceAccount.create"
    value = "false"
  }

  set {
    name  = "serviceAccount.name"
    value = "aws-load-balancer-controller"
  }

  set {
    name  = "region"
    value = var.aws_region
  }

  set {
    name  = "vpcId"
    value = var.vpc_id
  }

  depends_on = [kubernetes_service_account.albc]
}
