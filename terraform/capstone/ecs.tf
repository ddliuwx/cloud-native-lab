resource "aws_ecs_cluster" "this" {
  name = "${var.project_name}-ecs-cluster"

}

resource "aws_cloudwatch_log_group" "this" {
  name              = "/ecs/${var.project_name}-log-group"
  retention_in_days = 7

}

resource "aws_ecs_task_definition" "this" {
  family                   = "${var.project_name}-ecs-task"
  network_mode             = "awsvpc"
  requires_compatibilities = ["FARGATE"]
  cpu                      = "256"
  memory                   = "512"
  execution_role_arn       = module.execution_role.role_arn
  task_role_arn            = module.task_role.role_arn
  container_definitions = jsonencode([
    {
      name      = "${var.project_name}-container"
      image     = "nginx:latest"
      essential = true
      portMappings = [
        {
          containerPort = 80
          hostPort      = 80
          protocol      = "tcp"
        }
      ]
      logConfiguration = {
        logDriver = "awslogs"
        options = {
          awslogs-group         = aws_cloudwatch_log_group.this.name
          awslogs-region        = "ap-southeast-2"
          awslogs-stream-prefix = "${var.project_name}-ecs"
        }
      }
    }
  ])
}