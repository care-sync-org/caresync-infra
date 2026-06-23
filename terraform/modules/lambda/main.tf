resource "aws_sns_topic" "alerts" {
  name = "${var.cluster_name}-alerts"
}
resource "null_resource" "email" {
  triggers = {
    endpoint  = var.notification_email
    topic_arn = aws_sns_topic.alerts.arn
  }

  provisioner "local-exec" {
    command = "aws sns subscribe --topic-arn ${aws_sns_topic.alerts.arn} --protocol email --notification-endpoint ${var.notification_email}"
  }
}
resource "aws_iam_role" "lambda_exec" {
  name = "${var.cluster_name}-reminder-lambda-role"
  assume_role_policy = jsonencode({
    Version = "2012-10-17", Statement = [{ Action = "sts:AssumeRole", Principal = { Service = "lambda.amazonaws.com" }, Effect = "Allow" }]
  })
}
resource "aws_iam_role_policy_attachment" "vpc_access" {
  role       = aws_iam_role.lambda_exec.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaVPCAccessExecutionRole"
}
resource "aws_iam_role_policy" "lambda_policy" {
  role = aws_iam_role.lambda_exec.name
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      { Effect = "Allow", Action = "secretsmanager:GetSecretValue", Resource = var.secret_arn },
      { Effect = "Allow", Action = "ses:SendEmail", Resource = "*" }
    ]
  })
}
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/functions/appointment-reminder"
  output_path = "${path.module}/functions/appointment-reminder.zip"
}

resource "aws_lambda_function" "appointment_reminder" {
  function_name    = "${var.cluster_name}-appointment-reminder"
  role             = aws_iam_role.lambda_exec.arn
  handler          = "index.handler"
  runtime          = "nodejs20.x"
  filename         = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout          = 60
  memory_size      = 256

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = [var.security_group_id]
  }

  environment {
    variables = {
      SECRET_NAME    = var.secret_name
      SES_FROM_EMAIL = var.ses_from_email
    }
  }
}

resource "aws_cloudwatch_event_rule" "reminder_schedule" {
  name                = "${var.cluster_name}-reminder-schedule"
  description         = "Trigger the appointment reminder lambda"
  schedule_expression = var.reminder_schedule
}

resource "aws_cloudwatch_event_target" "reminder_target" {
  rule      = aws_cloudwatch_event_rule.reminder_schedule.name
  target_id = "appointment-reminder-lambda"
  arn       = aws_lambda_function.appointment_reminder.arn
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.appointment_reminder.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.reminder_schedule.arn
}
