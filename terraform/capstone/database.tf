module "database" {
  source                     = "../modules/rds"
  identifier                 = "${var.project_name}-db"
  vpc_id                     = module.vpc.vpc_id
  subnet_ids                 = [module.vpc.private_subnet_id, module.vpc.private_subnet_b_id]
  publicly_accessible        = false
  allowed_security_group_ids = [aws_security_group.ecs_task.id]

}