# API Gateway to send & get data and trigger Lambda writer function
#######################################################################################################################################
resource "aws_apigatewayv2_api" "http_api" {
  name            = "flightsyte-api"
  protocol_type   = "HTTP"
  ip_address_type = "dualstack"
  description     = "API Gateway endpoint for FlightSyte."
  tags = {
    Name        = "flightSyte"
    Environment = "development"
  }
}

# Api Gateway Integrations and Routes
#--------------------------------------------------------------------------------------------------------------------------------------
resource "aws_apigatewayv2_integration" "search_post_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"

  connection_type    = "INTERNET"
  description        = "API Gateway integration for the post method with flight search function"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.flight_search_function.arn

  payload_format_version = "2.0"

  depends_on = [aws_lambda_function.flight_search_function, aws_apigatewayv2_api.http_api]
}

resource "aws_apigatewayv2_route" "search_post_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /search"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.api_authorizer.id

  target     = "integrations/${aws_apigatewayv2_integration.search_post_integration.id}"
  depends_on = [aws_apigatewayv2_api.http_api]
}

#--------------------------------------------------------------------------------------------------------------------------------------

resource "aws_apigatewayv2_integration" "post_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"

  connection_type    = "INTERNET"
  description        = "API Gateway integration for the post method with Lambda writer function"
  integration_method = "POST"
  integration_uri    = aws_lambda_function.writer_function.arn

  payload_format_version = "2.0"

  depends_on = [aws_lambda_function.writer_function, aws_apigatewayv2_api.http_api]
}

resource "aws_apigatewayv2_route" "post_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /alert"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.api_authorizer.id

  target     = "integrations/${aws_apigatewayv2_integration.post_integration.id}"
  depends_on = [aws_apigatewayv2_api.http_api]
}

#-------------------------------------------------------------------------------------------------------------------------------------

resource "aws_apigatewayv2_integration" "get_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"

  connection_type        = "INTERNET"
  description            = "API Gateway integration for the get method with Lambda reader function"
  integration_method     = "GET"
  integration_uri        = aws_lambda_function.reader_function.arn
  payload_format_version = "2.0"

  depends_on = [aws_lambda_function.reader_function, aws_apigatewayv2_api.http_api]
}

resource "aws_apigatewayv2_route" "get_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "GET /alert"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.api_authorizer.id

  target     = "integrations/${aws_apigatewayv2_integration.get_integration.id}"
  depends_on = [aws_apigatewayv2_api.http_api]
}

#-------------------------------------------------------------------------------------------------------------------------------------

resource "aws_apigatewayv2_integration" "delete_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"

  connection_type        = "INTERNET"
  description            = "API Gateway integration for the delete method with Lambda delete function"
  integration_method     = "DELETE"
  integration_uri        = aws_lambda_function.delete_function.arn
  payload_format_version = "2.0"

  depends_on = [aws_lambda_function.delete_function, aws_apigatewayv2_api.http_api]
}

resource "aws_apigatewayv2_route" "delete_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "DELETE /alert"

  authorization_type = "JWT"
  authorizer_id      = aws_apigatewayv2_authorizer.api_authorizer.id


  target     = "integrations/${aws_apigatewayv2_integration.delete_integration.id}"
  depends_on = [aws_apigatewayv2_api.http_api]
}

#-------------------------------------------------------------------------------------------------------------------------------------
resource "aws_apigatewayv2_integration" "chatbot_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"

  connection_type        = "INTERNET"
  description            = "API Gateway integration for the chatbot Lambda function"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.chatbot_function.arn
  payload_format_version = "2.0"

  depends_on = [aws_lambda_function.chatbot_function, aws_apigatewayv2_api.http_api]
}

resource "aws_apigatewayv2_route" "chatbot_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /chatbot"

  target     = "integrations/${aws_apigatewayv2_integration.chatbot_integration.id}"
  depends_on = [aws_apigatewayv2_api.http_api]
}

#-------------------------------------------------------------------------------------------------------------------------------------

resource "aws_apigatewayv2_integration" "subscribe_integration" {
  api_id           = aws_apigatewayv2_api.http_api.id
  integration_type = "AWS_PROXY"

  connection_type        = "INTERNET"
  description            = "API Gateway integration for the subscribe method with Lambda subscribe function"
  integration_method     = "POST"
  integration_uri        = aws_lambda_function.subscribe_function.arn
  payload_format_version = "2.0"

  depends_on = [aws_lambda_function.subscribe_function, aws_apigatewayv2_api.http_api]
}

resource "aws_apigatewayv2_route" "subscribe_route" {
  api_id    = aws_apigatewayv2_api.http_api.id
  route_key = "POST /subscribe"

  target     = "integrations/${aws_apigatewayv2_integration.subscribe_integration.id}"
  depends_on = [aws_apigatewayv2_api.http_api]
}

#-------------------------------------------------------------------------------------------------------------------------------------

resource "aws_apigatewayv2_stage" "api_gateway_stage" {
  api_id      = aws_apigatewayv2_api.http_api.id
  name        = "$default"
  auto_deploy = true
  access_log_settings {
    destination_arn = aws_cloudwatch_log_group.api_gw_logs.arn
    format          = "$context.requestId $context.status $context.routeKey $context.authorizer.error $context.error.message $context.error.messageString $context.integration.error $context.integrationErrorMessage"
  }
}

resource "aws_apigatewayv2_deployment" "api_gateway_deployment" {
  api_id = aws_apigatewayv2_api.http_api.id

  lifecycle {
    create_before_destroy = true
  }

  triggers = {
    redeployment = sha1(jsonencode(aws_apigatewayv2_api.http_api))
  }

  depends_on = [aws_apigatewayv2_api.http_api, aws_apigatewayv2_stage.api_gateway_stage, aws_apigatewayv2_route.post_route,
    aws_apigatewayv2_route.get_route, aws_apigatewayv2_route.delete_route,
    aws_apigatewayv2_route.search_post_route, aws_apigatewayv2_route.chatbot_route,
    aws_apigatewayv2_route.subscribe_route]
}

resource "aws_apigatewayv2_authorizer" "api_authorizer" {
  api_id          = aws_apigatewayv2_api.http_api.id
  authorizer_type = "JWT"
  # authorizer_uri                    = aws_cognito_user_pool.FlightSyteUserPool.endpoint
  identity_sources = ["$request.header.Authorization"]
  name             = "flightsyte-authorizer"

  jwt_configuration {
    audience = [aws_cognito_user_pool_client.FlightSyteClient.id]
    issuer   = "https://${aws_cognito_user_pool.FlightSyteUserPool.endpoint}"
  }

  depends_on = [aws_cognito_user_pool.FlightSyteUserPool, aws_cognito_user_pool_client.FlightSyteClient]
}
# Logging key value pairs for api gateway logging
# { "requestId":"$context.requestId",
# "ip": "$context.identity.sourceIp", "requestTime":"$context.requestTime", "httpMethod":"$context.httpMethod",
# "routeKey":"$context.routeKey", "status":"$context.status","protocol":"$context.protocol",
# "responseLength":"$context.responseLength", "integration error": "$context.integration.error" ,
# "Integration error message":"$context.integrationErrorMessage", "error":"$context.error.message",
# "responseType":"$context.error.responseType", "message string":"$context.error.messageString"