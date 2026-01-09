# Cloudatch Logs for API Gateway
#######################################################################################################################################
resource "aws_api_gateway_account" "api_gateway_account" {
  cloudwatch_role_arn = aws_iam_role.cloudwatch.arn
}

data "aws_iam_policy_document" "assume_role" {
  statement {
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["apigateway.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "cloudwatch" {
  name               = "api-gateway-cloudwatch-global"
  assume_role_policy = data.aws_iam_policy_document.assume_role.json
}

data "aws_iam_policy_document" "cloudwatch" {
  statement {
    effect = "Allow"

    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:DescribeLogGroups",
      "logs:DescribeLogStreams",
      "logs:PutLogEvents",
      "logs:GetLogEvents",
      "logs:FilterLogEvents",
    ]

    resources = ["*"]
  }
}

resource "aws_iam_role_policy" "cloudwatch" {
  name   = "LimitedAPIGatewayCloudWatchAccess"
  role   = aws_iam_role.cloudwatch.id
  policy = data.aws_iam_policy_document.cloudwatch.json
}

resource "aws_cloudwatch_log_group" "api_gw_logs" {
  name = "apiGateway/logs/flightSyte"

  retention_in_days = 7

  tags = {
    Name        = "flightSyte"
    Environment = "development"
  }
}

resource "aws_cloudwatch_log_group" "ecs" {
  name              = "/ecs/FlightSyte_Task"
  retention_in_days = 7

  tags = {
    Name        = "flightSyte"
    Environment = "development"
  }
}
#######################################################################################################################################