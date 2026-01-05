# EventBrdge(CloudWatch Event Rule) to invoke the messsage processor Lambda
###################################################################
resource "aws_cloudwatch_event_rule" "processor_rule" {
  name        = "flight-processor-rule"
  description = "Triggers the flight processor Lambda every day at 8 AM UTC."

  schedule_expression = "cron(0 8 * * ? *)"
}

resource "aws_cloudwatch_event_target" "lambda_target" {
  rule      = aws_cloudwatch_event_rule.processor_rule.name
  target_id = "SendToLambda"
  arn       = aws_lambda_function.processor_function.arn
}