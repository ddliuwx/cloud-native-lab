resource "aws_ecs_service" "this" {
  name            = "${var.project_prefix}-phase11-nginx-service"
  cluster         = aws_ecs_cluster.this.id
  task_definition = aws_ecs_task_definition.this.arn
  desired_count   = 1
  launch_type     = "FARGATE"

  network_configuration {
    subnets          = [module.vpc.public_subnet_id]
    security_groups  = [aws_security_group.ecs_task.id]
    assign_public_ip = true
  }

}