# IAM Role and Policy for Lambda Processor Function
#######################################################################################################################################
resource "aws_iam_role_policy" "flight_search_iam_policy" {
  name = var.flight_search_iam_policy_name
  role = aws_iam_role.flight_search_assume_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Statement1",
        "Effect" : "Allow",
        "Action" : [
          "ssm:GetParameters"
        ],
        "Resource" : [
          "arn:aws:ssm:eu-north-1:408852977582:parameter/AMS_API_KEY",
          "arn:aws:ssm:eu-north-1:408852977582:parameter/AMS_API_SECRET",
          "arn:aws:ssm:eu-north-1:408852977582:parameter/SMTP_PASSWORD",
          "arn:aws:ssm:eu-north-1:408852977582:parameter/SMTP_USER"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "flight_search_assume_role" {
  name = var.flight_search_assume_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name        = "flightSyte"
    Environment = "development"
  }
}
#######################################################################################################################################


# IAM Role and Policy for Lambda Writer Function
#######################################################################################################################################
resource "aws_iam_role_policy" "dynamo_iam_policy" {
  name = var.writer_iam_policy_name
  role = aws_iam_role.writer_assume_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Statement1",
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:PutItem"
        ],
        "Resource" : [
          aws_dynamodb_table.flightsyte-dynamodb-table.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role" "writer_assume_role" {
  name = var.writer_assume_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name        = "flightSyte"
    Environment = "development"
  }
}
#######################################################################################################################################

# IAM Role and Policy for Lambda Reader Function
#######################################################################################################################################

resource "aws_iam_role_policy" "reader_iam_policy" {
  name = var.reader_iam_policy_name
  role = aws_iam_role.reader_assume_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Statement1",
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:Query"

        ],
        "Resource" : [
          aws_dynamodb_table.flightsyte-dynamodb-table.arn,
        ]
      }
    ]
  })
}

resource "aws_iam_role" "reader_assume_role" {
  name = var.reader_assume_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name        = "flightSyte"
    Environment = "development"
  }
}
#######################################################################################################################################


# IAM Role and Policy for Lambda Delete Function
#######################################################################################################################################

resource "aws_iam_role_policy" "delete_iam_policy" {
  name = var.delete_iam_policy_name
  role = aws_iam_role.delete_assume_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Statement1",
        "Effect" : "Allow",
        "Action" : [
          "dynamodb:DeleteItem",
        ],
        "Resource" : [
          aws_dynamodb_table.flightsyte-dynamodb-table.arn,
        ]
      }
    ]
  })
}

resource "aws_iam_role" "delete_assume_role" {
  name = var.delete_assume_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name        = "flightSyte"
    Environment = "development"
  }
}
#######################################################################################################################################


# IAM Role and Policy for Lambda Processor Function
#######################################################################################################################################

resource "aws_iam_role_policy" "processor_iam_policy" {
  name = var.processor_iam_policy_name
  role = aws_iam_role.processor_assume_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" = [
      {
        Sid    = "DynamoDBAccess"
        Effect = "Allow"
        Action = [
          "dynamodb:Query",
          "dynamodb:DeleteItem",
          "dynamodb:UpdateItem"
        ]
        Resource = [
          aws_dynamodb_table.flightsyte-dynamodb-table.arn,
          "${aws_dynamodb_table.flightsyte-dynamodb-table.arn}/index/GSI1"
        ]
      },
      {
        Sid    = "SSMAccess"
        Effect = "Allow"
        Action = [
          "ssm:GetParameters"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_role" "processor_assume_role" {
  name = var.processor_assume_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name        = "flightSyte"
    Environment = "development"
  }
}
#######################################################################################################################################


# IAM Role and Policy for Chatbot Processor Function
#######################################################################################################################################

resource "aws_iam_role_policy" "chatbot_iam_policy" {
  name = var.chatbot_iam_policy_name
  role = aws_iam_role.chatbot_assume_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Statement1",
        "Effect" : "Allow",
        "Action" : [
          "bedrock:InvokeModel",
          "ssm:GetParameters"
        ],
        "Resource" : [
          "arn:aws:bedrock:us-east-1::foundation-model/us.amazon.nova-2-lite-v1:0",
          "arn:aws:ssm:eu-north-1:408852977582:parameter/GEMINI_AI_API_KEY"
        ]
      }
    ]
  })
}

resource "aws_iam_role" "chatbot_assume_role" {
  name = var.chatbot_assume_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name        = "flightSyte"
    Environment = "development"
  }
}
#######################################################################################################################################

# IAM Role and Policy for Subscribe Processor Function
#######################################################################################################################################

resource "aws_iam_role_policy" "subscribe_iam_policy" {
  name = var.subscribe_iam_policy_name
  role = aws_iam_role.subscribe_assume_role.id

  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement" : [
      {
        "Sid" : "Statement1",
        "Effect" : "Allow",
        "Action" : [
          "sns:Subscribe"
        ],
        "Resource" : [
          aws_sns_topic.flightsyte_sns_topic.arn
        ]
      }
    ]
  })
}

resource "aws_iam_role" "subscribe_assume_role" {
  name = var.subscribe_assume_role

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Sid    = ""
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      },
    ]
  })

  tags = {
    Name        = "flightSyte"
    Environment = "development"
  }
}
#######################################################################################################################################


# AWS Managed Policy Attachments to IAM roles for CloudWatch Logs
#######################################################################################################################################
resource "aws_iam_role_policy_attachment" "flight_search_lambda_logs" {
  role       = aws_iam_role.flight_search_assume_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "writer_lambda_logs" {
  role       = aws_iam_role.writer_assume_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "reader_lambda_logs" {
  role       = aws_iam_role.reader_assume_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "delete_lambda_logs" {
  role       = aws_iam_role.delete_assume_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "processor_lambda_logs" {
  role       = aws_iam_role.processor_assume_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "chatbot_lambda_logs" {
  role       = aws_iam_role.chatbot_assume_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "subscribe_lambda_logs" {
  role       = aws_iam_role.subscribe_assume_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}
#######################################################################################################################################


# IAM Role and Policy for ECS Task Execution
#######################################################################################################################################
resource "aws_iam_role" "ecs_execution_role" {
  name = "flightsyte-ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role" "ecs_task_role" {
  name = "ecsTaskRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect    = "Allow"
      Principal = { Service = "ecs-tasks.amazonaws.com" }
      Action    = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_execution_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

resource "aws_iam_role_policy_attachment" "ssm_read_policy" {
  role       = aws_iam_role.ecs_task_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}

resource "aws_iam_role_policy_attachment" "ssm_read_policy_for_exec_role" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMReadOnlyAccess"
}
#######################################################################################################################################