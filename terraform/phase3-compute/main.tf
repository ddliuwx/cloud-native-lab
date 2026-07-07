terraform {
  required_providers {
    aws={
        source = "hashicorp/aws"
        version = "~> 5.0"
    }
  }
}

provider "aws" {
  region = "ap-southeast-2"
}
# lookup the default VPC and its subnets in the current region
data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

data "aws_ami" "al2023" {
  most_recent = true
  owners      = ["amazon"]

  filter {
    name   = "name"
    values = ["al2023-ami-*-x86_64"]
  }

  filter {
    name = "virtualization-type"
    values = ["hvm"]
  }
}

resource "aws_security_group" "web" {
  name        = "ddliu-phase3-web-sg"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description = "Allow HTTP traffic from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "Allow SSH traffic from my IP"
    from_port   = 22
    to_port     = 22
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

    tags = {
      Name = "ddliu-phase3-web-sg"
    }
}

resource "aws_instance" "web" {
  ami           = data.aws_ami.al2023.id
  instance_type = "t3.micro"
  subnet_id     = tolist(data.aws_subnets.default.ids)[0]
  vpc_security_group_ids = [aws_security_group.web.id]
  key_name = aws_key_pair.deployer.key_name
  user_data = file("${path.module}/user_data.sh")

  metadata_options {
    http_endpoint = "enabled"
    http_tokens = "required"
    http_put_response_hop_limit = 1
  }

  tags = {
    Name = "ddliu-phase3-web-instance"
  }
  
}

resource "aws_key_pair" "deployer" {
  key_name   = "ddliu-phase3-deployer"
    public_key = file("~/.ssh/tf-learning.pub")
}



