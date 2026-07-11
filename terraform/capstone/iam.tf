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
  source              = "../modules/iam-role"
  role_name           = "${var.project_name}-ecs-execution-role"
  assume_role_policy  = data.aws_iam_policy_document.ecs_task_trust.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"]
}

data "aws_iam_policy_document" "ecs_exec" {
  statement {
    actions = [
      "ssmmessages:CreateControlChannel",
      "ssmmessages:CreateDataChannel",
      "ssmmessages:OpenControlChannel",
      "ssmmessages:OpenDataChannel",
    ]
    resources = ["*"]
  }
}

resource "aws_iam_policy" "ecs_exec" {
  name   = "${var.project_name}-ecs-exec-policy"
  policy = data.aws_iam_policy_document.ecs_exec.json
}

module "task_role" {
  source              = "../modules/iam-role"
  role_name           = "${var.project_name}-ecs-task-role"
  assume_role_policy  = data.aws_iam_policy_document.ecs_task_trust.json
  managed_policy_arns = [aws_iam_policy.ecs_exec.arn]
}