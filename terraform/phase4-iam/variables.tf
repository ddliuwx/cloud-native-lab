variable "s3_target_bucket_name" {
  description = "the one bucket this role is allowed to read from"
  type = string
  default = "ddliu-bucket-name"
}

variable "github_repo" {
  description = "the GitHub repo allowed to assume this role, in owner/repo format"
  type = string
  default = "ddliuwx/cloud-native-lab"
}