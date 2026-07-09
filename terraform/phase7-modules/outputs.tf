output "vpc_id" {
  value = module.vpc.vpc_id
}

output "public_subnet_id" {
  value = module.vpc.public_subnet_id
}

output "private_subnet_id" {
  value = module.vpc.private_subnet_id
}

output "instance_id" {
  value = module.ec2.instance_id
}

output "public_ip" {
  value = module.ec2.public_ip
}

output "security_group_id" {
  value = module.ec2.security_group_id
}

output "ec2_role_arn" {
  value = module.ec2_s3_readonly_role.role_arn
}

output "github_actions_role_arn" {
  value = module.github_actions_role.role_arn
}

output "ec2_instance_profile_name" {
  value = module.ec2_s3_readonly_role.instance_profile_name
}

output "app_data_bucket_id" {
  value = module.app_data_bucket.bucket_id
}

output "lambda_function_name" {
  value = module.hello_lambda.function_name
}

output "db_endpoint" {
  value = module.database.endpoint
}