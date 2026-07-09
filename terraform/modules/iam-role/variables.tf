variable "role_name" {
  type = string
}

variable "assume_role_policy" {
  description = "trust policy json"
  type = string
}

variable "managed_policy_arns" {
  description = "list of managed policy arns"
  type = list(string)
  default = []
}

variable "create_instance_profile" {
  description = "whether to create an instance profile"
  type = bool
  default = false
}