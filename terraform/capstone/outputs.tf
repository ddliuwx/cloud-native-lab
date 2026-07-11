output "alb_dns_name" {
  value = aws_lb.this.dns_name
}

output "rds_endpoint" {
  value = module.database.endpoint
}

output "ecs_cluster_name" {
  value = aws_ecs_cluster.this.name
}

output "ecs_service_name" {
  value = aws_ecs_service.this.name
}
