variable "project_prefix" {
  type    = string
  default = "ddliu2026"
}

variable "my_ip" {
  description = "Your public IP address, to restrict EKS public endpoint access"
  type        = string
}