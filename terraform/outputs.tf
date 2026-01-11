output "flightsyte_public_subnet" {
  value = aws_subnet.flightsyte_public_subnet[*].id
}

output "flightsyte_private_subnet" {
  value = aws_subnet.flightsyte_private_subnet[*].id
}

output "vpc_id" {
  value = aws_vpc.flightsyte_vpc.id
}

output "alb_dns_name" {
  value = aws_lb.flightsyte_frontend_alb.dns_name
}