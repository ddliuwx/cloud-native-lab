variable "project_name" {
  type = string
}

variable "vpc_id" {
  description = "passed in from vpc module's output"
  type        = string
}

variable "subnet_id" {
  description = "passed in from vpc module's output"
  type        = string
}

variable "instance_type" {
  type    = string
  default = "t3.micro"
}