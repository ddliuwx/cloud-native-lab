resource "aws_db_subnet_group" "default" {
  name       = "learn-db-subnet-group"
  subnet_ids = data.aws_subnets.default.ids
}

resource "aws_security_group" "rds" {
  name        = "phase5-rds-sg"
  description = "Security group for phase5 learning RDS instance"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "mysql from my ip only"
    from_port   = 3306
    to_port     = 3306
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

resource "aws_db_instance" "learning" {
  identifier     = "phase5-learning-db"
  engine         = "mysql"
  engine_version = "8.0"
  instance_class = "db.t3.micro"

  allocated_storage = 20
  storage_type      = "gp2"
  storage_encrypted = true

  db_subnet_group_name   = aws_db_subnet_group.default.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  manage_master_user_password = true
  username                    = "admin"

  multi_az            = false
  publicly_accessible = true
  skip_final_snapshot = true
  deletion_protection = false

  tags = {
    name = "phase5-learning-db"
  }
  backup_retention_period    = 7
  apply_immediately          = true
  auto_minor_version_upgrade = true
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

