resource "aws_ecs_service" "this" {
  name                   = "${var.project_name}-ecs-service"
  cluster                = aws_ecs_cluster.this.id
  task_definition        = aws_ecs_task_definition.this.arn
  desired_count          = 2
  launch_type            = "FARGATE"
  enable_execute_command = true

  network_configuration {
    subnets          = [module.vpc.private_subnet_id, module.vpc.private_subnet_b_id]
    security_groups  = [aws_security_group.ecs_task.id]
    assign_public_ip = false
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.this.arn
    container_name   = "${var.project_name}-container"
    container_port   = 80
  }

  depends_on = [aws_lb_listener.this]
}