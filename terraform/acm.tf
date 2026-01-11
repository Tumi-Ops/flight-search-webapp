# AWS ACM Certificate for Flightsyte UI ALB
####################################################################################################################
resource "aws_acm_certificate" "flightsyte_cert" {
  domain_name       = aws_lb.flightsyte_frontend_alb.dns_name
  validation_method = "EMAIL"
  lifecycle {
    create_before_destroy = true
  }

  tags = {
    Name = "flightsyte-cert"
  }
}

resource "aws_acm_certificate_validation" "flightsyte_acm_validation" {
  certificate_arn = aws_acm_certificate.flightsyte_cert.arn
}