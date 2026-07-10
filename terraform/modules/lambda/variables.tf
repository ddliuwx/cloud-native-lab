variable "function_name" {
  type = string
}

variable "source_file" {
  description = "the path of lambda code file"
  type        = string
}

variable "handler" {
  type = string
}

variable "role_arn" {
  description = "from modules/iam-role output"
  type        = string
}

variable "runtime" {
  type    = string
  default = "python3.12"
}