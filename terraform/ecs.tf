# ECS Cluster, Task Definition, and Service for FlightSyte Application
#######################################################################################################################################
resource "aws_ecs_cluster" "ecs_cluster" {
  name = "majestic-flightsyte-cluster"

  setting {
    name  = "containerInsights"
    value = "enhanced"
  }
  tags = {
    Environment = "test"
    Project     = "FlightSyte"
  }
}

resource "aws_ecs_task_definition" "flightsyte_task" {
  family                   = "FlightSyte_Task"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = 512
  memory                   = 1024
  execution_role_arn       = aws_iam_role.ecs_execution_role.arn
  task_role_arn            = aws_iam_role.ecs_task_role.arn


  container_definitions = jsonencode([
    {
      name  = "flightsyte"
      image = "${aws_ecr_repository.ecr_repo.repository_url}:latest"

      portMappings = [{
        containerPort = 5000
        hostPort      = 5000
        protocol      = "tcp"
      }]

      secrets = [
        { name = "FLASK_SECRET_KEY", valueFrom = "arn:aws:ssm:eu-north-1:408852977582:parameter/FLASK_SECRET_KEY" }
      ]

      essential = true

      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = "/ecs/FlightSyte_Task"
          awslogs-region        = "eu-north-1"
          awslogs-stream-prefix = "ecs"
        }
      }
    }
  ])
  tags = {
    Environment = "test"
    Project     = "FlightSyte"
  }
  depends_on = [ aws_ecr_repository.ecr_repo.repository_url ]
}

resource "aws_ecs_service" "flightsyte_app" {
  name                              = "flightsyte-service"
  cluster                           = aws_ecs_cluster.ecs_cluster.id
  task_definition                   = aws_ecs_task_definition.flightsyte_task.arn
  desired_count                     = 2
  launch_type                       = "FARGATE"
  health_check_grace_period_seconds = 30

  network_configuration {
    subnets          = aws_subnet.flightsyte_private_subnet.*.id
    security_groups  = [aws_security_group.flightsyte_ecs_sg.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.flightsyte_frontend_tg.arn
    container_name   = "flightsyte"
    container_port   = 5000
  }

  lifecycle {
    ignore_changes = [desired_count]
  }

  depends_on = [aws_lb_listener.flightsyte_frontend_https]
  tags = {
    Environment = "test"
    Project     = "FlightSyte"
  }
}

#######################################################################################################################################
