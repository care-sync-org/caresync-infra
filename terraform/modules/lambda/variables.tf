variable "vpc_id" {}
variable "subnet_ids" {}
variable "security_group_id" {}
variable "secret_name" {}
variable "secret_arn" {}
variable "ses_from_email" {}
variable "notification_email" {}
variable "reminder_schedule" {
  description = "EventBridge cron expression for the reminder lambda"
  type        = string
}