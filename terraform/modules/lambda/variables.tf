variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "security_group_id" {
  type = string
}

variable "secret_name" {
  type = string
}

variable "secret_arn" {
  type = string
}

variable "ses_from_email" {
  type = string
}

variable "notification_email" {
  type = string
}

variable "reminder_schedule" {
  description = "EventBridge cron expression for the reminder lambda"
  type        = string
}

variable "cluster_name" {
  description = "Cluster name used as a prefix for resource naming"
  type        = string
}