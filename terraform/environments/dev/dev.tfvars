project_name       = "CareSync"
environment        = "dev"
domain_name        = "caresync-project.online"
db_name            = "caresync_dev"
s3_bucket_prefix   = "caresync-docs-dev-"
node_instance_type = "t3.medium"
node_min_size      = 2
node_max_size      = 3
node_desired_size  = 3
single_nat         = true
multi_az           = false
reminder_schedule  = "rate(1 hour)"
gitops_repo_url    = "https://github.com/care-sync-org/caresync-gitops.git"
gitops_branch      = "dev"

aws_region   = "us-east-1"
vpc_cidr     = "10.0.0.0/16"
cluster_name = "caresync-dev"
db_username  = "postgres"

notification_email = "nandanasuresh2468+1@gmail.com"
ses_from_email     = "nandanasuresh2468@gmail.com"
