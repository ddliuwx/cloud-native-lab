resource "aws_iam_role" "this" {
  name = var.role_name
  assume_role_policy = var.assume_role_policy
}

resource "aws_iam_role_policy_attachment" "this" {
  for_each = {for idx, arn in var.managed_policy_arns : tostring(idx) =>arn}
  role     = aws_iam_role.this.name
  policy_arn = each.value
  
}

resource "aws_iam_instance_profile" "this" {
    count = var.create_instance_profile ? 1 : 0
  name = "${var.role_name}-profile"
  role = aws_iam_role.this.name
  
}