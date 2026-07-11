#!/usr/bin/env bash
# Spins up the capstone three-tier architecture (VPC + NAT Gateway + RDS +
# ECS Fargate + ALB) and verifies it end-to-end via curl.
#
# The remote state backend (S3 bucket + DynamoDB lock table) is expected to
# either already exist, or get bootstrapped here if it doesn't - this repo's
# convention has been to destroy that backend too when fully tearing down
# (see destroy.sh), so a fresh start needs to recreate it first.
#
# Usage: ./start.sh
set -euo pipefail
cd "$(dirname "$0")"

BUCKET="tf-state-ddliu2026-capstone"

if ! aws s3api head-bucket --bucket "$BUCKET" 2>/dev/null; then
  echo "==> Remote state backend not found, bootstrapping it first..."
  (cd ../phase1-backend/bootstrap && terraform init -input=false && terraform apply -var="unique_suffix=ddliu2026-capstone")
fi

echo "==> terraform init"
terraform init -input=false

echo "==> terraform plan (review this before it applies)"
terraform plan -out=tfplan

echo "==> terraform apply (applying the plan reviewed above)"
terraform apply tfplan
rm -f tfplan

ALB_DNS=$(terraform output -raw alb_dns_name)
CLUSTER=$(terraform output -raw ecs_cluster_name)
SERVICE=$(terraform output -raw ecs_service_name)

echo "==> Waiting for the ECS service to reach steady state..."
aws ecs wait services-stable --cluster "$CLUSTER" --services "$SERVICE"

echo "==> Verifying via curl (ALB health checks can take a minute or two to warm up)..."
for i in $(seq 1 24); do
  if curl -sf "http://${ALB_DNS}" >/dev/null; then
    echo ""
    echo "Success! App is reachable at: http://${ALB_DNS}"
    echo "RDS endpoint (private, only reachable from the ECS task security group): $(terraform output -raw rds_endpoint)"
    exit 0
  fi
  sleep 5
done

echo ""
echo "Warning: curl didn't succeed within 2 minutes. Check target health manually:"
echo "  http://${ALB_DNS}"
exit 1
