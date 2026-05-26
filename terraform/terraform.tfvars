aws_region = "us-east-1"

project_name = "calculator-app"

vpc_cidr = "10.0.0.0/16"

public_subnets = [
  "10.0.1.0/24",
  "10.0.2.0/24"
]

private_subnets = [
  "10.0.3.0/24",
  "10.0.4.0/24"
]

availability_zones = [
  "us-east-1a",
  "us-east-1b"
]

cpu = 256
memory = 512

desired_count = 2

min_capacity = 2
max_capacity = 4

container_port = 80
