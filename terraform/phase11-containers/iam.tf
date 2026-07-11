data "aws_iam_policy_document" "ecs_task_trust" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type        = "Service"
      identifiers = ["ecs-tasks.amazonaws.com"]
    }
  }
}

module "execution_role" {
  source             = "../modules/iam-role"
  role_name          = "${var.project_prefix}-phase11-ecs-execution-role"
  assume_role_policy = data.aws_iam_policy_document.ecs_task_trust.json
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
  ]
}