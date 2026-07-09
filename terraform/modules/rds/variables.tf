variable "identifier" {
  type = string
}

variable "vpc_id" {
  type = string
}

variable "subnet_ids" {
  type = list(string)
}

variable "my_ip" {
  type = string
}

variable "db_port" {
  type = number
  default = 3306
}

variable "engine" {
  type = string
  default = "mysql"
}

variable "engine_version" {
  type = string
  default = "8.0"
}

variable "instance_class" {
  type = string
  default = "db.t3.micro"
}

variable "allocated_storage" {
  type = number
  default = 20
}

variable "username" {
  type = string
  default = "admin"
}

variable "publicly_accessible" {
  type = bool
  default = true
}