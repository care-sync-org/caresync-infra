module "eks" {
  source                                   = "terraform-aws-modules/eks/aws"
  version                                  = "20.14.0"
  cluster_name                             = var.cluster_name
  cluster_version                          = "1.31"
  vpc_id                                   = var.vpc_id
  subnet_ids                               = var.subnet_ids
  control_plane_subnet_ids                 = var.subnet_ids
  create_cluster_security_group            = false
  cluster_security_group_id                = var.cluster_sg_id
  create_node_security_group               = false
  enable_irsa                              = true
  cluster_endpoint_public_access           = true
  enable_cluster_creator_admin_permissions = true

  access_entries = {
    local_admin = {
      kubernetes_groups = []
      principal_arn     = "arn:aws:iam::664685894054:user/nandana"
      
      policy_associations = {
        admin = {
          policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = {
            type = "cluster"
          }
        }
      }
    }
  }
  eks_managed_node_groups = {
    main = {
      ami_type               = "AL2023_x86_64_STANDARD"
      instance_types         = [var.node_instance_type]
      min_size               = var.node_min_size
      max_size               = var.node_max_size
      desired_size           = var.node_desired_size
      vpc_security_group_ids = [var.node_sg_id]
      iam_role_additional_policies = {
        CloudWatchAgentServerPolicy = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
      }
    }
  }
  cluster_addons = {
    coredns                         = { resolve_conflicts_on_create = "OVERWRITE", resolve_conflicts_on_update = "OVERWRITE" }
    vpc-cni                         = { resolve_conflicts_on_create = "OVERWRITE", resolve_conflicts_on_update = "OVERWRITE" }
    kube-proxy                      = { resolve_conflicts_on_create = "OVERWRITE", resolve_conflicts_on_update = "OVERWRITE" }
    amazon-cloudwatch-observability = { resolve_conflicts_on_create = "OVERWRITE", resolve_conflicts_on_update = "OVERWRITE" }
  }
}