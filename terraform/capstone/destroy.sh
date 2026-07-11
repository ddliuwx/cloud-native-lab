#!/usr/bin/env bash
# Tears down every resource this capstone module created (VPC, NAT Gateway,
# RDS, ECS Fargate, ALB, IAM roles).
#
# Usage: ./destroy.sh
set -euo pipefail
cd "$(dirname "$0")"

echo "==> terraform plan -destroy (review this before it destroys anything)"
terraform plan -destroy -out=tfplan.destroy

echo "==> terraform apply (destroying everything reviewed above)"
terraform apply tfplan.destroy
rm -f tfplan.destroy

echo ""
echo "==> Done. Spot-check for leftovers:"
echo "  aws ecs list-clusters"
echo "  aws elbv2 describe-load-balancers"
echo "  aws rds describe-db-instances"
echo "  aws ec2 describe-vpcs --filters Name=tag:Name,Values=ddliu2026-capstone-vpc"

# The remote state backend (S3 bucket + DynamoDB lock table) is a separate
# resource from a separate root module (phase1-backend/bootstrap) - it isn't
# touched by the destroy above. It costs next to nothing to leave running
# (idle S3 storage + pay-per-request DynamoDB with no traffic), but tearing
# it down too gets you back to a genuinely empty AWS account. If you do,
# start.sh will automatically recreate it next time you run it.
echo ""
read -r -p "Also destroy the remote state backend (S3 bucket + DynamoDB lock table)? [y/N] " REPLY
if [[ "$REPLY" =~ ^[Yy]$ ]]; then
  echo "==> Destroying remote state backend..."
  (cd ../phase1-backend/bootstrap && terraform destroy -var="unique_suffix=ddliu2026-capstone")
fi
