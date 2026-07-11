resource "aws_ecs_cluster" "this" {
  name = "${var.project_prefix}-phase11-cluster"
}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.project_prefix}-phase11"
  retention_in_days = 7
}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.project_prefix}-phase11-nginx"
  requires_compatibilities = ["FARGATE"]
  network_mode             = "awsvpc"
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = module.execution_role.role_arn

  container_definitions = jsonencode([
    {
      name      = "nginx"
      image     = "nginx:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = "ap-southeast-2"
          awslogs-stream-prefix = "nginx"
        }
      }
    }
  ])
}