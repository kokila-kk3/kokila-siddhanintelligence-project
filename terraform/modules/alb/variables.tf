variable "vpc_id" {}

variable "public_subnets" {
  type = list(string)
}

variable "alb_sg" {}

variable "container_port" {}
