terraform {
  required_version = ">= 1.5.0"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

resource "aws_db_subnet_group" "this" {
  name       = "${var.identifier}-subnet-group"
  subnet_ids = var.subnet_ids
}

resource "aws_security_group" "this" {
  name        = "${var.identifier}-sg"
  description = "Security group for RDS instance ${var.identifier}"
  vpc_id      = var.vpc_id

  ingress {
    description = "DB access from my IP only"
    from_port   = var.db_port
    to_port     = var.db_port
    protocol    = "tcp"
    cidr_blocks = ["${var.my_ip}/32"]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "this" {
  identifier     = var.identifier
  engine         = var.engine
  engine_version = var.engine_version
  instance_class = var.instance_class

  allocated_storage = var.allocated_storage
  storage_type      = "gp2"
  storage_encrypted = true

  db_subnet_group_name   = aws_db_subnet_group.this.name
  vpc_security_group_ids = [aws_security_group.this.id]

  manage_master_user_password = true
  username                    = var.username

  multi_az                   = false
  publicly_accessible        = var.publicly_accessible
  skip_final_snapshot        = true
  deletion_protection        = false
  auto_minor_version_upgrade = true
  copy_tags_to_snapshot      = true
}