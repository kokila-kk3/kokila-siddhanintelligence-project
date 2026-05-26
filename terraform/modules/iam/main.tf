# -----------------------------------
# ECS TASK EXECUTION ROLE
# -----------------------------------
resource "aws_iam_role" "ecs_execution_role" {
  name = "ecsTaskExecutionRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "ecs-tasks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "ecs_policy" {
  role       = aws_iam_role.ecs_execution_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonECSTaskExecutionRolePolicy"
}

# -----------------------------------
# IAM USER
# -----------------------------------
resource "aws_iam_user" "terraform_user" {
  name = var.iam_user_name
}

# -----------------------------------
# ECS FULL ACCESS
# -----------------------------------
resource "aws_iam_user_policy_attachment" "ecs_full" {
  user       = aws_iam_user.terraform_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonECS_FullAccess"
}

# -----------------------------------
# EC2 FULL ACCESS
# -----------------------------------
resource "aws_iam_user_policy_attachment" "ec2_full" {
  user       = aws_iam_user.terraform_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2FullAccess"
}

# -----------------------------------
# ECR FULL ACCESS
# -----------------------------------
resource "aws_iam_user_policy_attachment" "ecr_full" {
  user       = aws_iam_user.terraform_user.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryFullAccess"
}

# -----------------------------------
# CLOUDWATCH FULL ACCESS
# -----------------------------------
resource "aws_iam_user_policy_attachment" "cloudwatch_full" {
  user       = aws_iam_user.terraform_user.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchFullAccess"
}

# -----------------------------------
# AUTOSCALING FULL ACCESS
# -----------------------------------
resource "aws_iam_user_policy_attachment" "autoscaling_full" {
  user       = aws_iam_user.terraform_user.name
  policy_arn = "arn:aws:iam::aws:policy/AutoScalingFullAccess"
}

# -----------------------------------
# IAM FULL ACCESS
# -----------------------------------
resource "aws_iam_user_policy_attachment" "iam_full" {
  user       = aws_iam_user.terraform_user.name
  policy_arn = "arn:aws:iam::aws:policy/IAMFullAccess"
}
