# Network configuration for ECS and ALB
########################################################################################################################

# Availability Zones
########################
data "aws_availability_zones" "available" {}

# VPC
#------------------------------------------------------------------------------------------------------
resource "aws_vpc" "flightsyte_vpc" {
  cidr_block           = "10.0.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "flightsyte-vpc"
  }
}
#------------------------------------------------------------------------------------------------------

###################################
# Public resources
###################################

# Internet Gateway
#------------------------------------------------------------------------------------------------------
resource "aws_internet_gateway" "flightsyte_igw" {
  vpc_id = aws_vpc.flightsyte_vpc.id

  tags = {
    Name = "flightsyte-igw"
  }
}
#------------------------------------------------------------------------------------------------------


# Public Subnets and Route Tables
#------------------------------------------------------------------------------------------------------
resource "aws_subnet" "flightsyte_public_subnet" {
  count                   = 2
  vpc_id                  = aws_vpc.flightsyte_vpc.id
  cidr_block              = cidrsubnet("10.0.0.0/16", 8, count.index)
  availability_zone       = data.aws_availability_zones.available.names[count.index]
  map_public_ip_on_launch = true

  tags = {
    Name = "flightsyte-public-${count.index}"
  }
}

resource "aws_route_table" "flightsyte_public_route_table" {
  vpc_id = aws_vpc.flightsyte_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.flightsyte_igw.id
  }

  tags = {
    Name = "flightsyte-public-route-table"
  }
}

resource "aws_route_table_association" "public_route_table_assoc" {
  count          = 2
  subnet_id      = aws_subnet.flightsyte_public_subnet[count.index].id
  route_table_id = aws_route_table.flightsyte_public_route_table.id
}
#-------------------------------------------------------------------------------------------------------

# Security Group for ALB
#-------------------------------------------------------------------------------------------------------
resource "aws_security_group" "flightsyte_alb_sg" {
  name        = "flightsyte-alb-security-group"
  description = "Security group for flightsyte ALB"
  vpc_id      = aws_vpc.flightsyte_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_alb_tls_ipv4" {
  security_group_id = aws_security_group.flightsyte_alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  from_port         = 80
  ip_protocol       = "tcp"
  to_port           = 80
}

resource "aws_vpc_security_group_egress_rule" "allow_all_alb_traffic_ipv4" {
  security_group_id = aws_security_group.flightsyte_alb_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
#-------------------------------------------------------------------------------------------------------

# Application Load Balancer and Target Group
#-------------------------------------------------------------------------------------------------------
resource "aws_lb" "flightsyte_ui_alb" {
  name               = "flightsyte-ui-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.flightsyte_alb_sg.id]
  subnets            = [aws_subnet.flightsyte_public_subnet[0].id, aws_subnet.flightsyte_public_subnet[1].id]

  # access_logs {
  #   bucket  = aws_s3_bucket.lb_logs.id
  #   prefix  = "flightsyte-lb"
  #   enabled = true
  # }

  tags = {
    Name = "flightsyte-alb"
  }
}

resource "aws_lb_target_group" "flightsyte_ui_tg" {
  name        = "flightsyte-ui-tg"
  target_type = "ip"
  port        = 5000
  protocol    = "HTTP"
  vpc_id      = aws_vpc.flightsyte_vpc.id

  health_check {
    enabled             = true
    interval            = 60
    path                = "/health"
    port                = "traffic-port"
    protocol            = "HTTP"
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 30
    matcher             = "200"
  }

  tags = {
    Name = "flightsyte-ui-tg"
  }

}

resource "aws_lb_listener" "flightsyte_front_end" {
  load_balancer_arn = aws_lb.flightsyte_ui_alb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.flightsyte_ui_tg.arn
  }
}
#-------------------------------------------------------------------------------------------------------

# EIP
#-------------------------------------------------------------------------------------------------------

resource "aws_eip" "flightsyte_eip" {
  domain     = "vpc"
  depends_on = [aws_internet_gateway.flightsyte_igw]
}
#-------------------------------------------------------------------------------------------------------

###################################


###################################
# Private resources
###################################

# Private Subnets and Route Tables
#-------------------------------------------------------------------------------------------------------
resource "aws_subnet" "flightsyte_private_subnet" {
  count             = 2
  vpc_id            = aws_vpc.flightsyte_vpc.id
  cidr_block        = cidrsubnet("10.0.0.0/16", 8, count.index + 10)
  availability_zone = data.aws_availability_zones.available.names[count.index]

  tags = {
    Name = "flightsyte-private-${count.index}"
  }
}

resource "aws_route_table" "flightsyte_private_route_table" {
  vpc_id = aws_vpc.flightsyte_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.flightsyte_nat_gw.id
  }

  tags = {
    Name = "flightsyte-private-route-table"
  }
}


resource "aws_route_table_association" "private_route_table_assoc" {
  count          = 2
  subnet_id      = aws_subnet.flightsyte_private_subnet[count.index].id
  route_table_id = aws_route_table.flightsyte_private_route_table.id
}
#-------------------------------------------------------------------------------------------------------


# NAT Gateway
#-------------------------------------------------------------------------------------------------------
resource "aws_nat_gateway" "flightsyte_nat_gw" {
  allocation_id = aws_eip.flightsyte_eip.id
  subnet_id     = aws_subnet.flightsyte_public_subnet[0].id

  tags = {
    Name = "flightsyte NAT Gateway"
  }

  # To ensure proper ordering, it is recommended to add an explicit dependency
  # on the Internet Gateway for the VPC.
  depends_on = [aws_internet_gateway.flightsyte_igw]
}
#-------------------------------------------------------------------------------------------------------

# Security Group for ECS
#-------------------------------------------------------------------------------------------------------
resource "aws_security_group" "flightsyte_ecs_sg" {
  name        = "flightsyte-ecs-security-group"
  description = "Security group for flightsyte ECS"
  vpc_id      = aws_vpc.flightsyte_vpc.id
}

resource "aws_vpc_security_group_ingress_rule" "allow_ecs_tls_ipv4" {
  security_group_id            = aws_security_group.flightsyte_ecs_sg.id
  referenced_security_group_id = aws_security_group.flightsyte_alb_sg.id
  from_port                    = 5000
  ip_protocol                  = "tcp"
  to_port                      = 5000
}

resource "aws_vpc_security_group_egress_rule" "allow_all_ecs_traffic_ipv4" {
  security_group_id = aws_security_group.flightsyte_ecs_sg.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
#-------------------------------------------------------------------------------------------------------


########################################################################################################################
