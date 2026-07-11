#!/usr/bin/env bash
# Tears down every resource this capstone module created (VPC, NAT Gateway,
# RDS, ECS Fargate, ALB, IAM roles). Does NOT touch the remote state backend
# (S3 bucket + DynamoDB table) - that's a separate, one-time resource, see
# README.md.
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
