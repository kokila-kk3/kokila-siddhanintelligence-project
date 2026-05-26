variable "aws_region" {}
variable "project_name" {}

variable "vpc_cidr" {}

variable "public_subnets" {
  type = list(string)
}

variable "private_subnets" {
  type = list(string)
}

variable "availability_zones" {
  type = list(string)
}

variable "cpu" {}
variable "memory" {}

variable "desired_count" {}
variable "min_capacity" {}
variable "max_capacity" {}

variable "container_port" {}
variable "iam_user_name" {
  type = string
}
