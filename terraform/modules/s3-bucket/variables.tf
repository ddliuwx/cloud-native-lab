variable "bucket_name" {
  type = string
}

variable "enable_versioning" {
  type = bool
  default = true
}

variable "lifecycle_days" {
  description = "null presents that do not enable lifecycle rule"
  type = number
  default = null
}