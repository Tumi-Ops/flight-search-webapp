variable "flight_search_lambda_function_name" {
  description = "Unique name for the flight search Lambda function."
  type        = string
}

variable "writer_lambda_function_name" {
  description = "Unique name for the writer Lambda function."
  type        = string
}

variable "processor_lambda_function_name" {
  description = "Unique name for the processor Lambda function."
  type        = string
}

variable "reader_lambda_function_name" {
  description = "Unique name for the reader Lambda function."
  type        = string
}

variable "delete_lambda_function_name" {
  description = "Unique name for the delete Lambda function."
  type        = string
}

variable "chatbot_lambda_function_name" {
  description = "Unique name for the chatbot Lambda function"
}

variable "subscribe_lambda_function_name" {
  description = "Unique name for the subscribe Lambda function."
  type        = string
}

#--------------------------------------------------------------------------------------------------------------------------------------

variable "dynamodb_table_name" {
  description = "Name of the DynamoDB table."
  type        = string
}

#--------------------------------------------------------------------------------------------------------------------------------------

variable "flight_search_iam_policy_name" {
  description = "Name of the IAM policy for the flight search Lambda function."
  type        = string
}

variable "writer_iam_policy_name" {
  description = "Name of the IAM policy for the writer Lambda function."
  type        = string
}

variable "reader_iam_policy_name" {
  description = "Name of the IAM policy for the reader Lambda function."
  type        = string
}

variable "delete_iam_policy_name" {
  description = "Name of the IAM policy for the delete Lambda function."
  type        = string
}

variable "processor_iam_policy_name" {
  description = "Name of the IAM policy for the processor Lambda function."
  type        = string
}

variable "chatbot_iam_policy_name" {
  description = "Name of the IAM policy for the chatbot Lambda function."
  type        = string
}

variable "subscribe_iam_policy_name" {
  description = "Name of the IAM policy for the subscribe Lambda function."
  type        = string
}

#--------------------------------------------------------------------------------------------------------------------------------------

variable "flight_search_assume_role" {
  description = "Name of the IAM role for the flight search Lambda function."
  type        = string
}

variable "writer_assume_role" {
  description = "Name of the IAM role for the writer Lambda function."
  type        = string
}

variable "reader_assume_role" {
  description = "Name of the IAM role for the reader Lambda function."
  type        = string
}

variable "processor_assume_role" {
  description = "Name of the IAM role for the processor Lambda function."
  type        = string
}

variable "delete_assume_role" {
  description = "Name of the IAM role for the delete Lambda function."
  type        = string
}

variable "chatbot_assume_role" {
  description = "Name of the IAM role for the chatbot Lambda function."
  type        = string
}

variable "subscribe_assume_role" {
  description = "Name of the IAM role for the subscribe Lambda function."
  type        = string
}

#--------------------------------------------------------------------------------------------------------------------------------------

variable "amadeus_cities_endpoint" {
  description = "Amadeus endpoint for the cities API"
  type        = string
}

variable "amadeus_flight_offers_endpoint" {
  description = "Amadeus endpoint for the flight offers endpoint"
  type        = string
}

variable "amadeus_locations_endpoint" {
  description = "Amadeus endpoint for the locations API"
  type        = string
}

variable "amadeus_token_endpoint" {
  description = "Amadeus endpoint for the token API"
  type        = string
}

variable "gemini_ai_model" {
  description = "Googles Gemini AI model"
  type        = string
}
