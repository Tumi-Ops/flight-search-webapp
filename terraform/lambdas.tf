# Lambda Functions
#######################################################################################################################################
resource "aws_lambda_function" "flight_search_function" {
  filename      = "flightSearch-function.zip"
  function_name = var.flight_search_lambda_function_name
  role          = aws_iam_role.flight_search_assume_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.14"
  architectures = ["x86_64"]

  layers = [aws_lambda_layer_version.request_layer.arn]

  description = "Searches for flights."

  memory_size = 128
  timeout     = 120

  # Advanced logging configuration
  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "WARN"
  }

  # Ensure IAM role and log group are ready
  depends_on = [
    aws_iam_role.flight_search_assume_role, aws_iam_role_policy_attachment.flight_search_lambda_logs
  ]

  environment {
    variables = {
      AMADEUS_CITIES_ENDPOINT = var.amadeus_cities_endpoint
      AMADEUS_FLIGHT_OFFERS   = var.amadeus_flight_offers_endpoint
      AMADEUS_LOCATIONS       = var.amadeus_locations_endpoint
      AMADEUS_TOKEN_ENDPOINT  = var.amadeus_token_endpoint
    }
  }

  tags = {
    Name        = "flightSyte"
    Environment = "development"
  }
}
resource "aws_lambda_permission" "allow_flight_search_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.flight_search_function.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
  depends_on    = [aws_apigatewayv2_api.http_api]
}

#--------------------------------------------------------------------------------------------------------------------------------------

resource "aws_lambda_function" "writer_function" {
  filename      = "flightAlertWriter-function.zip"
  function_name = var.writer_lambda_function_name
  role          = aws_iam_role.writer_assume_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.14"
  architectures = ["x86_64"]

  description = "Lambda function to write flight alerts to DynamoDB."

  memory_size = 128
  timeout     = 30

  # Advanced logging configuration
  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "WARN"
  }

  # Ensure IAM role and log group are ready
  depends_on = [
    aws_iam_role.writer_assume_role, aws_iam_role_policy_attachment.writer_lambda_logs
  ]

  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table_name
    }
  }

  tags = {
    Name        = "flightSyte"
    Environment = "development"
  }
}

resource "aws_lambda_permission" "allow_writer_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.writer_function.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
  depends_on    = [aws_apigatewayv2_api.http_api]
}

#--------------------------------------------------------------------------------------------------------------------------------------

resource "aws_lambda_function" "reader_function" {
  filename      = "flightAlertReader-function.zip"
  function_name = var.reader_lambda_function_name
  role          = aws_iam_role.reader_assume_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.14"
  architectures = ["x86_64"]

  description = "Lambda function to read flight alerts from DynamoDB."

  memory_size = 128
  timeout     = 30

  # Advanced logging configuration
  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "WARN"
  }

  # Ensure IAM role and log group are ready
  depends_on = [
    aws_iam_role.reader_assume_role, aws_iam_role_policy_attachment.reader_lambda_logs
  ]

  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table_name
    }
  }

  tags = {
    Name        = "flightSyte"
    Environment = "development"
  }
}

resource "aws_lambda_permission" "allow_reader_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.reader_function.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
  depends_on    = [aws_apigatewayv2_api.http_api]
}

#--------------------------------------------------------------------------------------------------------------------------------------

resource "aws_lambda_function" "delete_function" {
  filename      = "flightAlertDelete-function.zip"
  function_name = var.delete_lambda_function_name
  role          = aws_iam_role.delete_assume_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.14"
  architectures = ["x86_64"]

  description = "Lambda function to delete flight alerts from DynamoDB."

  memory_size = 128
  timeout     = 30

  # Advanced logging configuration
  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "WARN"
  }

  # Ensure IAM role and log group are ready
  depends_on = [
    aws_iam_role.delete_assume_role, aws_iam_role_policy_attachment.delete_lambda_logs
  ]

  environment {
    variables = {
      TABLE_NAME = var.dynamodb_table_name
    }
  }

  tags = {
    Name        = "flightSyte"
    Environment = "development"
  }
}

resource "aws_lambda_permission" "allow_delete_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.delete_function.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
  depends_on    = [aws_apigatewayv2_api.http_api]
}

#--------------------------------------------------------------------------------------------------------------------------------------

resource "aws_lambda_function" "processor_function" {
  filename      = "flightAlertProcessor-function.zip"
  function_name = var.processor_lambda_function_name
  role          = aws_iam_role.processor_assume_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.14"
  architectures = ["x86_64"]

  layers = [aws_lambda_layer_version.request_layer.arn]

  description = "Processes flight data."

  memory_size = 128
  timeout     = 120

  # Advanced logging configuration
  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "WARN"
  }

  # Ensure IAM role and log group are ready
  depends_on = [
    aws_iam_role.processor_assume_role, aws_iam_role_policy_attachment.processor_lambda_logs
  ]

  environment {
    variables = {
      TABLE_NAME              = var.dynamodb_table_name
      AMADEUS_CITIES_ENDPOINT = var.amadeus_cities_endpoint
      AMADEUS_FLIGHT_OFFERS   = var.amadeus_flight_offers_endpoint
      AMADEUS_LOCATIONS       = var.amadeus_locations_endpoint
      AMADEUS_TOKEN_ENDPOINT  = var.amadeus_token_endpoint
    }
  }

  tags = {
    Name        = "flightSyte"
    Environment = "development"
  }
}

resource "aws_lambda_permission" "allow_eventbridge" {
  statement_id  = "AllowExecutionFromEventBridge"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.processor_function.function_name
  principal     = "events.amazonaws.com"
  source_arn    = aws_cloudwatch_event_rule.processor_rule.arn
  depends_on    = [aws_cloudwatch_event_rule.processor_rule]
}

#--------------------------------------------------------------------------------------------------------------------------------------

resource "aws_lambda_function" "subscribe_function" {
  filename      = "flightNewsSubscribe-function.zip"
  function_name = var.subscribe_lambda_function_name
  role          = aws_iam_role.subscribe_assume_role.arn
  handler       = "lambda_function.lambda_handler"
  runtime       = "python3.14"
  architectures = ["x86_64"]

  description = "Subscribes users to flight news."

  memory_size = 128
  timeout     = 30

  # Advanced logging configuration
  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "WARN"
  }

  # Ensure IAM role and log group are ready
  depends_on = [
    aws_iam_role.subscribe_assume_role, aws_iam_role_policy_attachment.subscribe_lambda_logs
  ]

  environment {
    variables = {
      SNS_TOPIC = aws_sns_topic.flightsyte_sns_topic.arn
    }
  }

  tags = {
    Name        = "flightSyte"
    Environment = "development"
  }
}

resource "aws_lambda_permission" "allow_subscribe_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.subscribe_function.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
  depends_on    = [aws_apigatewayv2_api.http_api]
}

#--------------------------------------------------------------------------------------------------------------------------------------

resource "aws_lambda_function" "chatbot_function" {
  image_uri     = "408852977582.dkr.ecr.eu-north-1.amazonaws.com/flightsyte-chatbot:latest"
  function_name = var.chatbot_lambda_function_name
  role          = aws_iam_role.chatbot_assume_role.arn
  package_type  = "Image"
  architectures = ["arm64"]

  image_config {
    entry_point = ["/lambda-entrypoint.sh"]
    command     = ["lambda_function.lambda_handler"]
  }

  description = "Chatbot functionality for FlightSyte."

  memory_size = 1024
  timeout     = 120

  # Advanced logging configuration
  logging_config {
    log_format            = "JSON"
    application_log_level = "INFO"
    system_log_level      = "WARN"
  }

  # Ensure IAM role and log group are ready
  depends_on = [
    aws_iam_role.chatbot_assume_role, aws_iam_role_policy_attachment.chatbot_lambda_logs
  ]

  environment {
    variables = {
      MODEL_ID = var.gemini_ai_model
    }
  }

  tags = {
    Name        = "flightSyte"
    Environment = "development"
  }
}

resource "aws_lambda_permission" "allow_chatbot_api_gateway" {
  statement_id  = "AllowExecutionFromAPIGateway"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.chatbot_function.arn
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_apigatewayv2_api.http_api.execution_arn}/*/*"
  depends_on    = [aws_apigatewayv2_api.http_api]
}

#--------------------------------------------------------------------------------------------------------------------------------------
resource "aws_lambda_layer_version" "request_layer" {
  filename            = "requests-layer.zip"
  layer_name          = "request_dependency_layer"
  description         = "Request dependency for processor Lambda function"
  compatible_runtimes = ["python3.14"]

  compatible_architectures = ["x86_64"]
}
#
# resource "aws_lambda_layer_version" "google_genai_layer" {
#   filename            = "google-genai-layer.zip"
#   layer_name          = "google_dependency_layer"
#   description         = "Google Genai dependency for chatbot Lambda function"
#   compatible_runtimes = ["python3.14"]
#
#   compatible_architectures = ["x86_64"]
# }