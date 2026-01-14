# # Amazon certificate for when domain is set up
# ########################################################################################################################
# resource "aws_acm_certificate" "flightsyte_cert" {
#   domain_name       = aws_lb.flightsyte_frontend_alb.dns_name
#   validation_method = "DNS"
#   lifecycle {
#     create_before_destroy = true
#   }
#
#     tags = {
#         Name = "flightsyte-cert"
#     }
# }
#
# resource "aws_acm_certificate_validation" "flightsyte_acm_validation" {
#   certificate_arn = aws_acm_certificate.flightsyte_cert.arn
# }
#
# resource "aws_route53_record" "example" {
#   for_each = {
#     for dvo in aws_acm_certificate.flightsyte_cert.domain_validation_options : dvo.domain_name => {
#       name   = dvo.resource_record_name
#       record = dvo.resource_record_value
#       type   = dvo.resource_record_type
#     }
#   }
#
#   allow_overwrite = true
#   name            = each.value.name
#   records         = [each.value.record]
#   ttl             = 60
#   type            = each.value.type
#   zone_id         = aws_route53_zone.example.zone_id
# }