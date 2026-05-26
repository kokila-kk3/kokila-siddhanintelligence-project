module "vpc" {
  source = "./modules/vpc"

  vpc_cidr        = var.vpc_cidr
  public_subnets  = var.public_subnets
  private_subnets = var.private_subnets
  availability_zones = var.availability_zones
}

module "security_group" {
  source = "./modules/security_group"

  vpc_id = module.vpc.vpc_id
}

module "ecr" {
  source = "./modules/ecr"

  name = var.project_name
}

module "cloudwatch" {
  source       = "./modules/cloudwatch"
  project_name = var.project_name
  # Connect the ECS module outputs to your CloudWatch module variables
  cluster_name = module.ecs.cluster_name
  service_name = module.ecs.service_name
}

module "iam" {
  source = "./modules/iam"
  iam_user_name = var.iam_user_name
}

module "alb" {
  source = "./modules/alb"

  vpc_id         = module.vpc.vpc_id
  public_subnets = module.vpc.public_subnets

  alb_sg         = module.security_group.alb_sg
  container_port = var.container_port
}

module "ecs" {
  source = "./modules/ecs"

  project_name = var.project_name

  cpu    = var.cpu
  memory = var.memory

  aws_region = var.aws_region

  desired_count = var.desired_count

  private_subnets = module.vpc.private_subnets

  ecs_sg = module.security_group.ecs_sg

  target_group_arn = module.alb.target_group_arn

  ecr_url = module.ecr.repository_url

  execution_role_arn = module.iam.execution_role_arn

  log_group = module.cloudwatch.log_group

  container_port = var.container_port
}

module "autoscaling" {
  source = "./modules/autoscaling"

  cluster_name = module.ecs.cluster_name
  service_name = module.ecs.service_name

  min_capacity = var.min_capacity
  max_capacity = var.max_capacity
}
