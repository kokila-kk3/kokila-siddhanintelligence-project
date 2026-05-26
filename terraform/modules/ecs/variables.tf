variable "project_name" {}

variable "cpu" {}
variable "memory" {}

variable "aws_region" {}

variable "desired_count" {}

variable "private_subnets" {
  type = list(string)
}

variable "ecs_sg" {}

variable "target_group_arn" {}

variable "ecr_url" {}

variable "execution_role_arn" {}

variable "log_group" {}

variable "container_port" {}
