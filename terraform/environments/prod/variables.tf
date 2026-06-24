variable "aws_region" {
  type = string
}
variable "vpc_cidr" {
  type = string
}
variable "cluster_name" {
  type = string
}
variable "db_username" {
  type = string
}
variable "notification_email" {
  type = string
}
variable "ses_from_email" {
  type = string
}

variable "project_name" {
  type = string
}
variable "environment" {
  type = string
}
variable "domain_name" {
  type = string
}
variable "db_name" {
  type = string
}
variable "s3_bucket_prefix" {
  type = string
}
variable "node_instance_type" {
  type = string
}
variable "node_min_size" {
  type = number
}
variable "node_max_size" {
  type = number
}
variable "node_desired_size" {
  type = number
}
variable "single_nat" {
  type = bool
}
variable "multi_az" {
  type = bool
}
variable "reminder_schedule" {
  type = string
}
variable "gitops_repo_url" {
  type = string
}
variable "gitops_branch" {
  type = string
}