variable "project_name" {
  description = "used as a naming prefix for resources"
  type = string
  default = "ddliu2026"
}

variable "vpc_cidr" {
  type = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidr" {
  type = string
  default = "10.0.1.0/24"
}

variable "private_subnet_cidr" {
  type = string
  default = "10.0.2.0/24"
}

variable "availability_zone" {
  type = string
  default = "ap-southeast-2a"
}

variable "secondary_availability_zone" {
  type = string
  default = "ap-southeast-2b"
}

variable "public_subnet_b_cidr" {
  type = string
  default = "10.0.4.0/24"
}