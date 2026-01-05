# AWS DynamoDB Table for FlightSyte Alerts
#######################################################################################################################################
resource "aws_dynamodb_table" "flightsyte-dynamodb-table" {
  name         = "FlightSyteAlerts"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "email"
  range_key    = "created_at"

  attribute {
    name = "email"
    type = "S"
  }

  attribute {
    name = "created_at"
    type = "S"
  }

  tags = {
    Name        = "flightSyte"
    Environment = "development"
  }

  attribute {
    name = "from_date"
    type = "S"
  }
  attribute {
    name = "status"
    type = "S"
  }

  global_secondary_index {
    name            = "GSI1"
    hash_key        = "status"
    projection_type = "ALL"
    range_key       = "from_date"
  }
}