resource "aws_sqs_queue" "dlq" {
  name              = "${var.cluster_name}-ai-dlq"
  kms_master_key_id = var.kms_key_arn
}
resource "aws_sqs_queue" "main" {
  name                       = "${var.cluster_name}-ai-queue"
  visibility_timeout_seconds = 300
  kms_master_key_id          = var.kms_key_arn
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 3
  })
}