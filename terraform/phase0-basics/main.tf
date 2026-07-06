
terraform {
  required_providers {
    local = {
        source = "hashicorp/local"
        version = "~> 2.5"
    }
  }
}

variable "greeting" {
  description = "the greeting text written to the file"
  type = string
  default = "Hello Terraform"
}

resource "local_file" "hello" {
  filename = "${path.module}/hello.txt"
  content = var.greeting
}

output "file_path" {
  description = "path of the generated file"
  value = local_file.hello.filename
}