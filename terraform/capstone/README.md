# Capstone: Three-Tier Web Architecture on AWS

A minimal, production-shaped three-tier architecture built with Terraform:
**ALB → ECS Fargate (private) → RDS (private)**, with remote state and a
GitHub Actions CI pipeline. See [`diagrams/architecture.svg`](diagrams/architecture.svg)
for the full picture.

- **Presentation tier**: Application Load Balancer, public subnets, two AZs
- **App tier**: ECS Fargate service, **private** subnets, no public IP, only reachable through the ALB
- **Data tier**: RDS MySQL, **private** subnets, `publicly_accessible = false`, only reachable from the app tier's security group
- **Egress**: a single NAT Gateway lets the private-subnet ECS tasks reach the internet to pull the container image

## Prerequisites

- AWS CLI configured with credentials that can create the resources above
- Terraform >= 1.5.0
- The remote state backend already bootstrapped (one-time setup, see below)

## One-time setup: remote state backend

This project's state lives in a dedicated S3 bucket + DynamoDB lock table,
separate from other phases' backends. It only needs to be created once:

```bash
cd ../phase1-backend/bootstrap
terraform apply -var="unique_suffix=ddliu2026-capstone"
```

This creates:
- S3 bucket: `tf-state-ddliu2026-capstone`
- DynamoDB table: `tf-state-lock-ddliu2026-capstone`

`capstone/main.tf` already points at this backend. If you ever need to
recreate it under a different name, update the `backend "s3"` block in
`main.tf` and re-run `terraform init` (Terraform will prompt to migrate
existing state — say `yes` if there's anything worth keeping, `no` if
starting fresh).

## Usage

### Start

```bash
./start.sh
```

This runs `terraform init` → `plan` → `apply`, waits for the ECS service to
reach steady state, then curls the ALB until the app responds (up to 2
minutes, since ALB health checks take a little while to pass after tasks
first launch).

Takes roughly 5-8 minutes end to end — the NAT Gateway and RDS instance are
the slow parts.

### Destroy

```bash
./destroy.sh
```

Runs `terraform plan -destroy` → `apply`, tearing down every resource this
module created. Takes roughly 10-15 minutes (NAT Gateway, RDS, and ALB
deletion each take a few minutes).

**Cost reminder**: while running, this stack costs real money per hour (NAT
Gateway, ALB, RDS, 2x Fargate tasks — roughly $0.15-0.20/hour combined).
Don't leave it running longer than you need it for.

Both scripts use `terraform plan -out=<file>` followed by `terraform apply
<file>`, not `-auto-approve` — the plan is always printed and applied
exactly as reviewed, never silently.

## Manual verification (optional, beyond what start.sh checks)

Get the ALB DNS name and RDS endpoint any time:

```bash
terraform output alb_dns_name
terraform output rds_endpoint
```

Verify the app tier can actually reach the data tier (not just that the
network path exists on paper) via ECS Exec:

```bash
CLUSTER=$(terraform output -raw ecs_cluster_name)
SERVICE=$(terraform output -raw ecs_service_name)
TASK=$(aws ecs list-tasks --cluster "$CLUSTER" --service-name "$SERVICE" --query 'taskArns[0]' --output text)

aws ecs execute-command --cluster "$CLUSTER" --task "$TASK" \
  --container ddliu2026-capstone-container --interactive --command "/bin/bash"

# inside the container shell:
bash -c 'echo > /dev/tcp/<rds-endpoint-from-above>/3306 && echo OPEN || echo CLOSED'
```

Requires the [Session Manager Plugin](https://docs.aws.amazon.com/systems-manager/latest/userguide/session-manager-working-with-install-plugin.html)
installed locally (`brew install --cask session-manager-plugin` on macOS).

## CI/CD

`.github/workflows/capstone-plan.yml` runs `terraform fmt/validate/plan`
against this directory on every PR touching `terraform/capstone/**`, using
GitHub OIDC to assume an AWS role (no long-lived credentials). `apply` stays
manual — CI never changes real infrastructure by itself.
