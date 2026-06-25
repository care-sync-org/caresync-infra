resource "aws_cloudwatch_metric_alarm" "dlq_not_empty" {
  alarm_name          = "${var.cluster_name}-dlq-not-empty"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "1"
  metric_name         = "ApproximateNumberOfMessagesVisible"
  namespace           = "AWS/SQS"
  period              = "300"
  statistic           = "Maximum"
  threshold           = "0"
  alarm_description   = "Alarm when DLQ has messages"
  alarm_actions       = [var.sns_topic_arn]
  dimensions          = { QueueName = var.sqs_dlq_name }
}

# ---------------------------------------------------------------------------
# EKS Node CPU Starvation Alarm
# ---------------------------------------------------------------------------
resource "aws_cloudwatch_metric_alarm" "eks_node_cpu_high" {
  alarm_name          = "${var.cluster_name}-high-node-cpu"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"               # Evaluate over 2 periods (10 mins total)
  metric_name         = "node_cpu_utilization"
  namespace           = "ContainerInsights"
  period              = "300"             # 5 minute periods
  statistic           = "Average"
  threshold           = "85"              # 85% CPU Utilization
  alarm_description   = "Alarm when EKS Cluster nodes average > 85% CPU for 10 minutes. Indicates severe compute starvation."
  alarm_actions       = [var.sns_topic_arn]

  dimensions = {
    ClusterName = var.cluster_name
  }
}