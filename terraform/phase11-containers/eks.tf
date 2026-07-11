data "aws_iam_policy_document" "eks_cluster_trust" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["eks.amazonaws.com"]
    }
  }

}

module "eks_cluster_role" {
  source              = "../modules/iam-role"
  role_name           = "${var.project_prefix}-phase11-eks-cluster-role"
  assume_role_policy  = data.aws_iam_policy_document.eks_cluster_trust.json
  managed_policy_arns = ["arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"]
}

resource "aws_eks_cluster" "this" {
  name     = "${var.project_prefix}-phase11-eks"
  role_arn = module.eks_cluster_role.role_arn

  vpc_config {
    subnet_ids          = [module.vpc.public_subnet_id, module.vpc.public_subnet_b_id]
    public_access_cidrs = ["${var.my_ip}/32"]
  }

  access_config {
    authentication_mode = "API"
  }

}

data "aws_caller_identity" "current" {}

resource "aws_eks_access_entry" "admin" {
  cluster_name  = aws_eks_cluster.this.name
  principal_arn = data.aws_caller_identity.current.arn

}

resource "aws_eks_access_policy_association" "admin" {
  cluster_name  = aws_eks_cluster.this.name
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
  principal_arn = data.aws_caller_identity.current.arn
  access_scope {
    type = "cluster"
  }
}