# Orphaned AWS Resources Checklist

Because I configured your Terraform modules to automatically tag every single resource with `Project = CareSync` and `ManagedBy = Terraform`, I was able to run a query against the AWS Resource Groups Tagging API to find exactly what the trainer missed!

Here is the exact list of resources still lingering in your AWS account. You can use this as a checklist to manually delete them from the AWS Console.

## Networking (VPC)
- [ ] `vpc-09d1c6cfa88a01f7d`
- [ ] `igw-024f4fd70726d5821` (Internet Gateway)
- [ ] `acl-0337a4fc2bd6efcee` (Network ACL)
- [ ] `rtb-0b0fa6908d1eab29f` (Route Table)
- [ ] `rtb-00a49514e6c267c04` (Route Table)
- [ ] `rtb-040a7c57c3451b9d0` (Route Table)
- [ ] `subnet-01ba18db12709843e`
- [ ] `subnet-0a4d4bb6cbaa8c14e`
- [ ] `subnet-045334d2ec1b0f1ea`
- [ ] `subnet-0d413b35204702965`
- [ ] `subnet-021c68a0fa52e8e75`
- [ ] `subnet-0ba6337d7c5ff1200`

## Security Groups
- [ ] `sg-07a4e4128dd160605`
- [ ] `sg-079683e4d3c8448f3`
- [ ] `sg-0b7389bdea433d273`
- [ ] `sg-019c39ec9e22e5849`
- [ ] `sg-05724baa42058ea3f`
- [ ] `sg-0c5a49ae9154bce05`

## Identity & Access Management (IAM)
- [ ] `oidc.eks.us-east-1.amazonaws.com/id/1B16E6E82DBDF90BE600AC837B50A84D` (OIDC Provider)
- [ ] `policy/caresync-dev-albc-policy`
- [ ] `policy/caresync-dev-cluster-ClusterEncryption...`

## Database (RDS)
- [ ] `caresync-dev-vpc` (Subnet Group)
- [ ] `caresync_dev-subnet-group` (Subnet Group)

## Compute & Storage
- [ ] `lt-0f4fd11713aed773a` (EC2 Launch Template)
- [ ] `caresync/app-secrets-b33219f6-fMIF8R` (Secrets Manager)

## Cryptography (KMS)
- [ ] `ad3dd0db-a2ba-4283-bb45-e8b16f425adf`
- [ ] `9d198b61-8423-4aa0-98fc-e41bdd655d7d`

## Messaging & Monitoring
- [ ] `caresync-ai-queue` (SQS)
- [ ] `caresync-ai-dlq` (SQS)
- [ ] `caresync-dev-dlq-not-empty` (CloudWatch Alarm)

## Elastic Container Registry (ECR)
*(Note: You usually want to **KEEP** these so you don't have to rebuild and re-push your Docker images!)*
- `repository/caresync/notification-service`
- `repository/caresync/user-service`
- `repository/caresync/auth-service`
- `repository/caresync/appointment-service`
- `repository/caresync/frontend`
- `repository/caresync/document-service`
- `repository/caresync/ai-service`
