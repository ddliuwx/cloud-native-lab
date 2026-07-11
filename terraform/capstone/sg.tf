resource "aws_security_group" "ecs_task" {
  name        = "${var.project_name}-ecs-task-sg"
  description = "Security group for capstone ECS Fargate tasks"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description     = "HTTP from ALB only"
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.alb.id]
  }
  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}