# resource "aws_ecr_repository" "ecr_repo" {
#   name                 = "flightsyte-repo"
#   image_tag_mutability = "IMMUTABLE_WITH_EXCLUSION"

#   image_tag_mutability_exclusion_filter {
#     filter      = "latest*"
#     filter_type = "WILDCARD"
#   }

#   encryption_configuration {
#     encryption_type = "AES256"
#   }

#   tags = {
#     Environment = "test"
#     Project     = "FlightSyte"
#   }
# }